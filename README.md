# Music Visualization App

A real-time 3D Mandelbulb fractal visualizer that reacts to music input. Built with Three.js and WebGL shaders for smooth audio-reactive animations.

## Features

- **Real-time Audio Analysis**: 7-band frequency analysis with beat detection
- **3D Mandelbulb Fractal**: Ray-marched fractal with dynamic shape morphing
- **Audio-Reactive Effects**: Shape changes, color shifts, and camera movements synced to music
- **Interactive Controls**: Adjustable parameters for intensity, power, colors, and more
- **Beat Detection**: Multi-level beat detection with visual impact effects
- **Responsive Design**: Adapts to different screen sizes and devices

## How to Use

1. **Load Music**: Click "Choose File" and select an audio file
2. **Adjust Settings**: Use the control panel to modify visual parameters
3. **Reset**: Click "Reset All" to restore default settings
4. **Pause**: Use the pause button to stop/start music and visuals

## Controls

- **Intensity**: Overall brightness and contrast
- **Power**: Fractal complexity and detail level
- **Hue Shift**: Color palette rotation
- **Shape Mod**: Audio-reactive shape deformation
- **Distortion**: Surface complexity and detail
- **Rotation Speed**: Camera and fractal rotation rate
- **Chaos**: Randomness in fractal generation
- **Morphing**: Organic shape transformations
- **Frequency Response**: Sensitivity to audio frequencies
- **Shape Regen**: Rate of shape regeneration
- **Beat Sync**: Beat detection sensitivity
- **Structure**: Fundamental fractal structure changes
- **Breathing**: Slow organic pulsing
- **Pulse**: Fast rhythmic pulsing
- **Movement Limit**: Constrains camera movement
- **Size Control**: Fractal scale adjustment
- **Color Palette**: Choose from 4 different color schemes
- **Saturation**: Color intensity
- **Brightness**: Overall brightness level

## Technical Details

- **WebGL Ray-marching**: Real-time 3D fractal rendering
- **Web Audio API**: High-resolution frequency analysis
- **Beat Detection**: Spectral flux analysis with attack/release envelopes
- **Adaptive Quality**: Performance-based quality adjustment
- **High DPI Support**: Crisp rendering on high-resolution displays

## Browser Compatibility

- Chrome (recommended)
- Firefox
- Safari
- Edge

Requires WebGL support and Web Audio API.

## Installation

No installation required. Simply open `index.html` in a web browser or serve via HTTP server:

```bash
python -m http.server 8000
```

## License

MIT License - feel free to use and modify for your projects.