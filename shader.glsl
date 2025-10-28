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
uniform float u_movementLimit;
uniform float u_sizeControl;
uniform float u_colorPalette;
uniform float u_saturation;
uniform float u_brightness;
uniform float u_adaptiveMaxSteps;
uniform float u_adaptiveMaxIterations;
uniform float u_superSamplingFactor;

#define MAX_STEPS 400
#define MAX_DIST 12.0
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
  
  // CYCLIC MORPHING SYSTEM - Creates patterns that return to original state
  
  // 1. CYCLIC POWER MODULATION - Changes fractal complexity in cycles
  float powerCycle = u_time * 0.3 + bass * 2.0 + mid * 1.5 + high * 1.0;
  float cyclicPower = u_power + sin(powerCycle) * 2.0 * u_shapeRegen + 
                     cos(powerCycle * 0.7) * 1.5 * u_structureChange;
  
  // 2. CYCLIC SCALE MODULATION - Changes fractal size in cycles (reduced range)
  float scaleCycle = u_time * 0.4 + bass * 1.8 + mid * 1.2 + high * 0.8;
  float cyclicScale = 1.0 + sin(scaleCycle) * 0.15 * u_shapeRegen + 
                     cos(scaleCycle * 0.6) * 0.1 * u_structureChange;
  
  // 3. CYCLIC ITERATION MODULATION - Changes fractal detail level
  float iterCycle = u_time * 0.25 + bass * 1.5 + mid * 1.0 + high * 0.7;
  float cyclicIterations = 8.0 + sin(iterCycle) * 2.0 * u_shapeRegen + 
                          cos(iterCycle * 0.8) * 1.5 * u_structureChange;
  
  // 4. CYCLIC SPATIAL MODULATION - Changes fractal position in cycles
  float spatialCycle = u_time * 0.35 + bass * 2.2 + mid * 1.6 + high * 1.1;
  vec3 cyclicOffset = vec3(
    sin(spatialCycle * 1.1) * 0.3 * u_shapeRegen * bass,
    cos(spatialCycle * 0.9) * 0.3 * u_shapeRegen * mid,
    sin(spatialCycle * 1.3) * 0.3 * u_shapeRegen * high
  );
  
  // 5. CYCLIC ROTATION MODULATION - Changes fractal orientation in cycles
  float rotCycle = u_time * 0.2 + bass * 1.7 + mid * 1.3 + high * 0.9;
  float cyclicRotX = sin(rotCycle) * 0.5 * u_structureChange;
  float cyclicRotY = cos(rotCycle * 0.8) * 0.4 * u_structureChange;
  float cyclicRotZ = sin(rotCycle * 1.2) * 0.3 * u_structureChange;
  
  // Apply cyclic transformations
  p += cyclicOffset;
  // Note: cyclicScale is now applied later with size control for better range management
  
  // Apply cyclic rotations
  mat3 cyclicRotX_mat = mat3(
    1.0, 0.0, 0.0,
    0.0, cos(cyclicRotX), -sin(cyclicRotX),
    0.0, sin(cyclicRotX), cos(cyclicRotX)
  );
  mat3 cyclicRotY_mat = mat3(
    cos(cyclicRotY), 0.0, sin(cyclicRotY),
    0.0, 1.0, 0.0,
    -sin(cyclicRotY), 0.0, cos(cyclicRotY)
  );
  mat3 cyclicRotZ_mat = mat3(
    cos(cyclicRotZ), -sin(cyclicRotZ), 0.0,
    sin(cyclicRotZ), cos(cyclicRotZ), 0.0,
    0.0, 0.0, 1.0
  );
  p = cyclicRotZ_mat * cyclicRotY_mat * cyclicRotX_mat * p;
  
  // 6. CYCLIC DISTORTION MODULATION - Changes fractal surface complexity
  float distortionCycle = u_time * 0.45 + bass * 2.5 + mid * 1.8 + high * 1.2;
  float cyclicDistortion = u_distortion + sin(distortionCycle) * 0.3 * u_shapeRegen + 
                          cos(distortionCycle * 0.7) * 0.2 * u_structureChange;
  
  // 7. CYCLIC CHAOS MODULATION - Changes fractal randomness
  float chaosCycle = u_time * 0.38 + bass * 2.1 + mid * 1.4 + high * 0.9;
  float cyclicChaos = u_chaos + sin(chaosCycle) * 0.4 * u_shapeRegen + 
                     cos(chaosCycle * 0.6) * 0.3 * u_structureChange;
  
  // 8. CYCLIC MORPHING MODULATION - Changes fractal organic movement
  float morphingCycle = u_time * 0.42 + bass * 2.3 + mid * 1.7 + high * 1.1;
  float cyclicMorphing = u_morphing + sin(morphingCycle) * 0.5 * u_shapeRegen + 
                        cos(morphingCycle * 0.8) * 0.4 * u_structureChange;
  
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
  
  // Reduced breathing behavior to prevent excessive size
  float breathingPhase = u_time * 0.2; // Slower breathing rate
  float breathing1 = sin(breathingPhase) * u_breathing * 0.05; // Much smaller effect
  float breathing2 = cos(breathingPhase * 0.7) * u_breathing * 0.04;
  float breathing3 = sin(breathingPhase * 1.3) * u_breathing * 0.03;
  
  // Reduced pulse behavior
  float pulsePhase = u_time * 0.8; // Slower pulse
  float pulse1 = sin(pulsePhase) * u_pulse * 0.08; // Much smaller effect
  float pulse2 = cos(pulsePhase * 0.8) * u_pulse * 0.06;
  
  // Reduced beat-synced pulse
  float beatPulse = u_beatIntensity * 0.15; // Much smaller beat effect
  
  // Apply breathing and pulse to position
  p += vec3(breathing1, breathing2, breathing3) + vec3(pulse1, pulse2, 0.0) + vec3(beatPulse);
  
  // Apply regeneration and structure changes
  p += regenOffset + structureMod;
  
  // Apply size control with better range management
  // Combine cyclic scale with user size control more intelligently
  float finalScale = u_sizeControl * (0.8 + 0.4 * cyclicScale); // Better range control
  p *= finalScale;
  
  // Ensure fractal is always visible - improved fallback
  if(finalScale < 0.2) p *= 5.0; // If combined scale is too small, make it visible
  if(finalScale > 3.0) p *= 0.5; // If combined scale is too large, reduce it
  
  // Use cyclic power modulation for dynamic shape changes
  float power = cyclicPower + bass * 0.8 + mid * 0.5 + high * 0.4;
  power += sin(u_time * 0.8 + bass * 2.0) * 0.15 * u_frequencyResponse;
  power += (bass + mid + high) * u_shapeRegen * 0.8;
  power += (breathing1 + breathing2) * 0.2;
  power += u_beatIntensity * 0.8;
  
  // Controlled multi-directional distortion (preserves 3D structure) - using cyclic values
  vec3 distortion1 = vec3(
    sin(p.x * 1.5 + u_time * 0.3 + bass * 1.5) * cyclicDistortion * bass * 0.3,
    cos(p.y * 1.2 + u_time * 0.4 + mid * 1.2) * cyclicDistortion * mid * 0.3,
    sin(p.z * 1.8 + u_time * 0.5 + high * 1.0) * cyclicDistortion * high * 0.3
  );
  
  // Subtle secondary distortion layer - using cyclic values
  vec3 distortion2 = vec3(
    cos(p.x * 2.0 + u_time * 0.2) * sin(p.y * 1.5 + u_time * 0.3) * cyclicChaos * bass * 0.2,
    sin(p.y * 1.8 + u_time * 0.4) * cos(p.z * 2.2 + u_time * 0.2) * cyclicChaos * mid * 0.2,
    cos(p.z * 2.1 + u_time * 0.3) * sin(p.x * 1.7 + u_time * 0.4) * cyclicChaos * high * 0.2
  );
  
  // Gentle morphing layer (preserves core shape) - using cyclic values
  vec3 morphing = vec3(
    sin(p.x * p.y * 0.2 + u_time * 0.6) * cos(p.z * 0.1 + u_time * 0.7) * cyclicMorphing * (bass + mid) * 0.15,
    cos(p.y * p.z * 0.15 + u_time * 0.8) * sin(p.x * 0.1 + u_time * 0.5) * cyclicMorphing * (mid + high) * 0.15,
    sin(p.z * p.x * 0.25 + u_time * 0.7) * cos(p.y * 0.2 + u_time * 0.9) * cyclicMorphing * (high + bass) * 0.15
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
  
  // Subtle chaotic transformation (preserves 3D structure) - using cyclic values
  float chaos = cyclicChaos * (bass + mid + high) * 0.15;
  p.x += sin(p.y * 1.2 + u_time * 0.8) * chaos;
  p.y += cos(p.z * 1.5 + u_time * 0.6) * chaos;
  p.z += sin(p.x * 1.8 + u_time * 0.9) * chaos;
  
  vec3 z=p;
  float dr=1.0;
  float r=0.0;
  int maxIter = int(min(cyclicIterations, u_adaptiveMaxIterations));
  int adaptiveMaxIter = int(u_adaptiveMaxIterations);
  for(int i=0;i<25;i++){ // Increased max iterations for more detail
    if(i >= maxIter || i >= adaptiveMaxIter) break;
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
  // Enhanced normal calculation with adaptive precision
  float eps = 0.0002 * (1.0 / u_superSamplingFactor); // Better precision with super-sampling
  vec2 e = vec2(1.0,-1.0)*0.5773*eps;
  vec3 n = normalize(e.xyy*map(p+e.xyy)+
                    e.yyx*map(p+e.yyx)+
                    e.yxy*map(p+e.yxy)+
                    e.xxx*map(p+e.xxx));
  
  // Additional refinement for better contours
  float eps2 = eps * 0.5;
  vec3 n2 = normalize(vec3(
    map(p + vec3(eps2, 0.0, 0.0)) - map(p - vec3(eps2, 0.0, 0.0)),
    map(p + vec3(0.0, eps2, 0.0)) - map(p - vec3(0.0, eps2, 0.0)),
    map(p + vec3(0.0, 0.0, eps2)) - map(p - vec3(0.0, 0.0, eps2))
  ));
  
  // Blend both normal calculations for better quality
  return normalize(mix(n, n2, 0.3));
}

void main(){
  vec2 uv=(gl_FragCoord.xy/u_resolution.xy)*2.0-1.0;
  uv.x*=u_resolution.x/u_resolution.y;

  // Enhanced camera motion with audio-reactive choreography
  float bass=u_audioLow;
  float mid=u_audioMid;
  float high=u_audioHigh;
  float t=u_time*0.2;
  
  // Fixed camera position - fractal should be visible
  float movementFactor = u_movementLimit; // User control for movement intensity
  float cameraOrbit = t * 0.05 * movementFactor + bass * 0.2 * movementFactor;
  float cameraRadius = 2.5 + sin(t*0.2)*0.1* movementFactor + u_energy * 0.2 * movementFactor;
  float cameraHeight = sin(t*0.1) * 0.05 * movementFactor + mid * 0.1 * movementFactor;
  
  vec3 ro = vec3(
    sin(cameraOrbit) * cameraRadius * 0.1 * movementFactor,
    cameraHeight,
    cos(cameraOrbit) * cameraRadius + 2.5
  );
  
  // Ensure camera is at reasonable distance
  if(length(ro) < 1.0) ro = normalize(ro) * 2.0;
  
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
  int adaptiveSteps = int(u_adaptiveMaxSteps);
  for(int i=0;i<400;i++){ // Max possible steps
    if(i >= adaptiveSteps) break;
    p=ro+rd*total;
    d=map(p);
    if(d<MIN_DIST || total>MAX_DIST) break;
    total+=d;
  }

  if(total<MAX_DIST){
    vec3 n=getNormal(p);
    float diff=clamp(dot(n,normalize(vec3(1.0,1.0,1.0))),0.0,1.0);
    
    // Enhanced color palette system
    float hue;
    if(u_colorPalette < 1.0) {
      // Palette 0: Classic rainbow
      hue = mod(u_hueShift + t*0.2 + bass*0.5, 1.0);
    } else if(u_colorPalette < 2.0) {
      // Palette 1: Ocean blues and teals
      hue = mod(0.5 + u_hueShift*0.3 + t*0.1 + mid*0.3, 1.0);
    } else if(u_colorPalette < 3.0) {
      // Palette 2: Fire reds and oranges
      hue = mod(0.05 + u_hueShift*0.2 + t*0.15 + high*0.4, 1.0);
    } else {
      // Palette 3: Cosmic purples and magentas
      hue = mod(0.8 + u_hueShift*0.4 + t*0.25 + (bass+mid+high)*0.2, 1.0);
    }
    
    vec3 base = hsv2rgb(vec3(hue, u_saturation, u_brightness));
    col = base * pow(diff, 0.8) * u_intensity * (0.7 + mid*0.6 + high*0.4);
    
    // Enhanced contour enhancement
    float edgeFactor = smoothstep(0.0, 0.02, d);
    float contourBoost = 1.0 + (1.0 - edgeFactor) * 0.3;
    col *= contourBoost;
    
    // Enhanced rim lighting with palette-aware colors
    float rim = 1.0 - abs(dot(n, normalize(vec3(uv, -1.0))));
    rim = pow(rim, 3.0);
    col += base * rim * 0.3 * u_brightness;
  }

  // Original glow
  col += vec3(0.2,0.1,0.3)*(0.1+0.9*exp(-0.2*total))*bass*1.5;
  col=pow(col,vec3(0.4545)); // gamma
  gl_FragColor=vec4(col,1.0);
}
