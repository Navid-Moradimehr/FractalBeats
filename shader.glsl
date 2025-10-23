precision highp float;

uniform vec2 u_resolution;
uniform float u_time;
uniform float u_audioLow;
uniform float u_audioMid;
uniform float u_audioHigh;
uniform float u_intensity;
uniform float u_power;
uniform float u_hueShift;
uniform float u_shapeMod;
uniform float u_distortion;
uniform float u_rotationSpeed;
uniform float u_chaos;
uniform float u_morphing;
uniform float u_frequencyResponse;

#define MAX_STEPS 150
#define MAX_DIST 8.0
#define MIN_DIST 0.001

vec3 hsv2rgb(vec3 c){
  vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0,4,2),6.0)-3.0)-1.0,0.0,1.0);
  rgb = rgb*rgb*(3.0-2.0*rgb);
  return c.z * mix(vec3(1.0), rgb, c.y);
}

float mandelbulb(vec3 p){
  // Audio-reactive shape modulation
  float bass = u_audioLow;
  float mid = u_audioMid;
  float high = u_audioHigh;
  
  // Multi-frequency power modulation
  float power = u_power + bass * 3.0 + mid * 2.0 + high * 1.5;
  power += sin(u_time * 0.8 + bass * 4.0) * 0.5 * u_frequencyResponse;
  
  // Complex multi-directional distortion
  vec3 distortion1 = vec3(
    sin(p.x * 1.2 + u_time * 0.4 + bass * 3.0) * u_distortion * bass,
    cos(p.y * 1.8 + u_time * 0.6 + mid * 2.5) * u_distortion * mid,
    sin(p.z * 2.3 + u_time * 0.8 + high * 2.0) * u_distortion * high
  );
  
  // Secondary distortion layer for more complexity
  vec3 distortion2 = vec3(
    cos(p.x * 3.1 + u_time * 0.3) * sin(p.y * 2.7 + u_time * 0.5) * u_chaos * bass,
    sin(p.y * 2.4 + u_time * 0.7) * cos(p.z * 3.3 + u_time * 0.4) * u_chaos * mid,
    cos(p.z * 2.8 + u_time * 0.6) * sin(p.x * 3.5 + u_time * 0.8) * u_chaos * high
  );
  
  // Tertiary morphing layer
  vec3 morphing = vec3(
    sin(p.x * p.y * 0.5 + u_time * 0.9) * cos(p.z * 0.3 + u_time * 1.1) * u_morphing * (bass + mid),
    cos(p.y * p.z * 0.4 + u_time * 1.2) * sin(p.x * 0.2 + u_time * 0.8) * u_morphing * (mid + high),
    sin(p.z * p.x * 0.6 + u_time * 1.0) * cos(p.y * 0.4 + u_time * 1.3) * u_morphing * (high + bass)
  );
  
  p += (distortion1 + distortion2 + morphing) * u_shapeMod;
  
  // Multi-axis audio-reactive rotation
  float rotAngleX = u_time * u_rotationSpeed + bass * 3.0 + sin(u_time * 0.5) * 0.5;
  float rotAngleY = u_time * u_rotationSpeed * 0.7 + mid * 2.5 + cos(u_time * 0.7) * 0.3;
  float rotAngleZ = u_time * u_rotationSpeed * 1.3 + high * 2.0 + sin(u_time * 0.9) * 0.4;
  
  // X-axis rotation
  mat3 rotX = mat3(
    1.0, 0.0, 0.0,
    0.0, cos(rotAngleX), -sin(rotAngleX),
    0.0, sin(rotAngleX), cos(rotAngleX)
  );
  
  // Y-axis rotation
  mat3 rotY = mat3(
    cos(rotAngleY), 0.0, sin(rotAngleY),
    0.0, 1.0, 0.0,
    -sin(rotAngleY), 0.0, cos(rotAngleY)
  );
  
  // Z-axis rotation
  mat3 rotZ = mat3(
    cos(rotAngleZ), -sin(rotAngleZ), 0.0,
    sin(rotAngleZ), cos(rotAngleZ), 0.0,
    0.0, 0.0, 1.0
  );
  
  // Apply all rotations
  p = rotZ * rotY * rotX * p;
  
  // Additional chaotic transformation
  float chaos = u_chaos * (bass + mid + high) * 0.5;
  p.x += sin(p.y * 2.0 + u_time * 1.5) * chaos;
  p.y += cos(p.z * 2.5 + u_time * 1.2) * chaos;
  p.z += sin(p.x * 3.0 + u_time * 1.8) * chaos;
  
  vec3 z=p;
  float dr=1.0;
  float r=0.0;
  for(int i=0;i<8;i++){
    r=length(z);
    if(r>2.0) break;
    float theta=acos(z.z/r);
    float phi=atan(z.y,z.x);
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
