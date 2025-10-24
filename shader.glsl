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
uniform float u_shapeRegen;
uniform float u_beatSync;
uniform float u_structureChange;
uniform float u_breathing;
uniform float u_pulse;
uniform float u_beatIntensity;
uniform float u_energy;

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
  
  // Music-synced shape regeneration using actual audio frequencies
  float regenPhase = u_time * u_beatSync + bass * 6.0 + mid * 4.0 + high * 2.0;
  
  // Fundamental structure changes - regenerate fractal shape (music-synced)
  vec3 regenOffset = vec3(
    sin(regenPhase * 1.2 + bass * 3.0) * u_shapeRegen * bass,
    cos(regenPhase * 0.8 + mid * 2.5) * u_shapeRegen * mid,
    sin(regenPhase * 1.5 + high * 2.0) * u_shapeRegen * high
  );
  
  // Structure morphing - change fundamental shape (music-synced)
  float structurePhase = u_time * u_structureChange + bass * 4.0 + mid * 3.0 + high * 2.0;
  vec3 structureMod = vec3(
    sin(structurePhase * 0.7 + bass * 2.0) * 0.3 * u_structureChange * bass,
    cos(structurePhase * 1.1 + mid * 1.5) * 0.3 * u_structureChange * mid,
    sin(structurePhase * 0.9 + high * 1.8) * 0.3 * u_structureChange * high
  );
  
  // Breathing behavior - slow organic oscillations
  float breathingPhase = u_time * 0.3; // Slow breathing rate
  float breathing1 = sin(breathingPhase) * u_breathing * 0.2;
  float breathing2 = cos(breathingPhase * 0.7) * u_breathing * 0.15;
  float breathing3 = sin(breathingPhase * 1.3) * u_breathing * 0.1;
  
  // Pulse behavior - faster, more rhythmic
  float pulsePhase = u_time * 1.2;
  float pulse1 = sin(pulsePhase) * u_pulse * 0.3;
  float pulse2 = cos(pulsePhase * 0.8) * u_pulse * 0.25;
  
  // Beat-synced pulse (triggered by actual beats)
  float beatPulse = u_beatIntensity * 0.5;
  
  // Apply breathing and pulse to position
  p += vec3(breathing1, breathing2, breathing3) + vec3(pulse1, pulse2, 0.0) + vec3(beatPulse);
  
  // Apply regeneration and structure changes
  p += regenOffset + structureMod;
  
  // Multi-frequency power modulation with breathing and beat sync
  float power = u_power + bass * 1.5 + mid * 1.0 + high * 0.8;
  power += sin(u_time * 0.8 + bass * 2.0) * 0.3 * u_frequencyResponse;
  power += (bass + mid + high) * u_shapeRegen * 1.5; // Music-synced power changes
  power += (breathing1 + breathing2) * 0.5; // Breathing affects complexity
  power += u_beatIntensity * 2.0; // Beat pulses increase complexity
  
  // Controlled multi-directional distortion (preserves 3D structure)
  vec3 distortion1 = vec3(
    sin(p.x * 1.5 + u_time * 0.3 + bass * 1.5) * u_distortion * bass * 0.3,
    cos(p.y * 1.2 + u_time * 0.4 + mid * 1.2) * u_distortion * mid * 0.3,
    sin(p.z * 1.8 + u_time * 0.5 + high * 1.0) * u_distortion * high * 0.3
  );
  
  // Subtle secondary distortion layer
  vec3 distortion2 = vec3(
    cos(p.x * 2.0 + u_time * 0.2) * sin(p.y * 1.5 + u_time * 0.3) * u_chaos * bass * 0.2,
    sin(p.y * 1.8 + u_time * 0.4) * cos(p.z * 2.2 + u_time * 0.2) * u_chaos * mid * 0.2,
    cos(p.z * 2.1 + u_time * 0.3) * sin(p.x * 1.7 + u_time * 0.4) * u_chaos * high * 0.2
  );
  
  // Gentle morphing layer (preserves core shape)
  vec3 morphing = vec3(
    sin(p.x * p.y * 0.2 + u_time * 0.6) * cos(p.z * 0.1 + u_time * 0.7) * u_morphing * (bass + mid) * 0.15,
    cos(p.y * p.z * 0.15 + u_time * 0.8) * sin(p.x * 0.1 + u_time * 0.5) * u_morphing * (mid + high) * 0.15,
    sin(p.z * p.x * 0.25 + u_time * 0.7) * cos(p.y * 0.2 + u_time * 0.9) * u_morphing * (high + bass) * 0.15
  );
  
  p += (distortion1 + distortion2 + morphing) * u_shapeMod;
  
  // Controlled multi-axis audio-reactive rotation
  float rotAngleX = u_time * u_rotationSpeed + bass * 1.5 + sin(u_time * 0.3) * 0.3;
  float rotAngleY = u_time * u_rotationSpeed * 0.8 + mid * 1.2 + cos(u_time * 0.4) * 0.2;
  float rotAngleZ = u_time * u_rotationSpeed * 1.1 + high * 1.0 + sin(u_time * 0.5) * 0.25;
  
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
  
  // Subtle chaotic transformation (preserves 3D structure)
  float chaos = u_chaos * (bass + mid + high) * 0.15;
  p.x += sin(p.y * 1.2 + u_time * 0.8) * chaos;
  p.y += cos(p.z * 1.5 + u_time * 0.6) * chaos;
  p.z += sin(p.x * 1.8 + u_time * 0.9) * chaos;
  
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

  // Enhanced camera motion with audio-reactive choreography
  float bass=u_audioLow;
  float mid=u_audioMid;
  float high=u_audioHigh;
  float t=u_time*0.2;
  
  // Dynamic camera position with audio-reactive movement
  float cameraOrbit = t * 0.1 + bass * 0.5;
  float cameraRadius = 2.5 + sin(t*0.5)*0.3 + u_energy * 0.5;
  float cameraHeight = sin(t*0.3) * 0.2 + mid * 0.3;
  
  vec3 ro = vec3(
    sin(cameraOrbit) * cameraRadius * 0.3,
    cameraHeight,
    cos(cameraOrbit) * cameraRadius + 2.5
  );
  
  // Audio-reactive camera direction
  vec3 rd = normalize(vec3(uv, -1.5 + bass*0.5 + u_beatIntensity*0.3));

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
    
    // Add subtle contour enhancement without changing colors
    // Use the existing color but enhance edges
    float edgeFactor = smoothstep(0.0, 0.02, d);
    float contourBoost = 1.0 + (1.0 - edgeFactor) * 0.3;
    col *= contourBoost;
    
    // Add subtle rim lighting using existing color
    float rim = 1.0 - abs(dot(n, normalize(vec3(uv, -1.0))));
    rim = pow(rim, 3.0);
    col += base * rim * 0.2;
  }

  // Original glow
  col += vec3(0.2,0.1,0.3)*(0.1+0.9*exp(-0.2*total))*bass*1.5;
  col=pow(col,vec3(0.4545)); // gamma
  gl_FragColor=vec4(col,1.0);
}
