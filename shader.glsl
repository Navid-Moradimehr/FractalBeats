precision highp float;

uniform vec2 u_resolution;
uniform float u_time;
uniform float u_audioLow;
uniform float u_audioMid;
uniform float u_audioHigh;
uniform float u_intensity;
uniform float u_power;
uniform float u_hueShift;

#define MAX_STEPS 150
#define MAX_DIST 8.0
#define MIN_DIST 0.001

vec3 hsv2rgb(vec3 c){
  vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0,4,2),6.0)-3.0)-1.0,0.0,1.0);
  rgb = rgb*rgb*(3.0-2.0*rgb);
  return c.z * mix(vec3(1.0), rgb, c.y);
}

float mandelbulb(vec3 p){
  vec3 z=p;
  float dr=1.0;
  float r=0.0;
  for(int i=0;i<8;i++){
    r=length(z);
    if(r>2.0) break;
    float theta=acos(z.z/r);
    float phi=atan(z.y,z.x);
    float power=u_power;
    float zr=pow(r,power);
    dr=pow(r,power-1.0)*power*dr+1.0;
    theta*=power;
    phi*=power;
    z=zr*vec3(sin(theta)*cos(phi),sin(theta)*sin(phi),cos(theta));
    z+=p;
  }
  return 0.5*log(r)*r/dr;
}

float map(vec3 p){
  return mandelbulb(p);
}

vec3 getNormal(vec3 p){
  float eps=0.0005;
  vec2 e=vec2(1.0,-1.0)*0.5773*eps;
  return normalize(e.xyy*map(p+e.xyy)+
                   e.yyx*map(p+e.yyx)+
                   e.yxy*map(p+e.yxy)+
                   e.xxx*map(p+e.xxx));
}

void main(){
  vec2 uv=(gl_FragCoord.xy/u_resolution.xy)*2.0-1.0;
  uv.x*=u_resolution.x/u_resolution.y;

  // camera motion
  float bass=u_audioLow;
  float mid=u_audioMid;
  float high=u_audioHigh;
  float t=u_time*0.2;
  vec3 ro=vec3(0.0,0.0,2.5+sin(t*0.5)*0.3);
  vec3 rd=normalize(vec3(uv, -1.5 + bass*0.5));

  // rotate camera slowly
  float a=t*0.3 + bass*0.5;
  mat2 rot = mat2(cos(a),-sin(a),sin(a),cos(a));
  ro.xz *= rot;
  rd.xz *= rot;

  float total=0.0;
  vec3 col=vec3(0.0);
  float d=0.0;
  vec3 p;
  for(int i=0;i<MAX_STEPS;i++){
    p=ro+rd*total;
    d=map(p);
    if(d<MIN_DIST || total>MAX_DIST) break;
    total+=d;
  }

  if(total<MAX_DIST){
    vec3 n=getNormal(p);
    float diff=clamp(dot(n,normalize(vec3(1.0,1.0,1.0))),0.0,1.0);
    float hue=mod(u_hueShift + t*0.2 + bass*0.5, 1.0);
    vec3 base=hsv2rgb(vec3(hue,1.0,1.0));
    col=base*pow(diff,0.8)*u_intensity*(0.7+mid*0.6+high*0.4);
  }

  // glow
  col += vec3(0.2,0.1,0.3)*(0.1+0.9*exp(-0.2*total))*bass*1.5;
  col=pow(col,vec3(0.4545)); // gamma
  gl_FragColor=vec4(col,1.0);
}
