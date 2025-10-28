# FractalBeats

A real-time 3D Mandelbulb fractal visualizer that reacts to music input. Built with Three.js and WebGL shaders for smooth audio-reactive animations.

**[Live Demo](https://navid-moradimehr.github.io/FractalBeats)** - Try it now in your browser!

## Features

- **Real-time Audio Analysis**: 7-band frequency analysis with beat detection
- **3D Mandelbulb Fractal**: Ray-marched fractal with dynamic shape morphing
- **Audio-Reactive Effects**: Shape changes, color shifts, and camera movements synced to music
- **Interactive Controls**: Adjustable parameters for intensity, power, colors, and more
- **Beat Detection**: Multi-level beat detection with visual impact effects
- **Responsive Design**: Adapts to different screen sizes and devices

## How to Use

1. **Open the App**: Visit the live demo link above
2. **Load Music**: Click "Choose File" and select an audio file from your device
3. **Adjust Settings**: Use the control panel to modify visual parameters
4. **Reset**: Click "Reset All" to restore default settings
5. **Pause**: Use the pause button to stop/start music and visuals

**Note**: The app runs entirely in your browser - no installation required!

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

## Local Development

To run locally for development:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Navid-Moradimehr/FractalBeats.git
   cd FractalBeats
   ```

2. **Serve locally** (optional):
   ```bash
   python -m http.server 8000
   ```
   Then open `http://localhost:8000` in your browser

3. **Or simply open** `index.html` directly in your browser

## Hosting

This app is designed to work perfectly with GitHub Pages:

- **Free hosting** with HTTPS enabled
- **Global CDN** for fast loading worldwide
- **Automatic updates** when you push changes
- **No server required** - runs entirely in the browser
- **WebGL rendering** handled by user's GPU
- **Web Audio API** processes audio in the browser

## License

MIT License - feel free to use and modify for your projects.