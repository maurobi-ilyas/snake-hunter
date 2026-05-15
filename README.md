# 🐍 SNAKE HUNTER

A modern, lightweight, and addictive Flutter game built with the **Flame Engine**. 

# 🧠 PROJECT DOCS SYSTEM
The folder `/project-docs` serves as the **Central Brain System** for this project. All development decisions, feature implementations, and optimizations must strictly adhere to the rules and states documented within:
- `SRS.do.js`: Software Requirements
- `GAME_RULES.do.js`: Gameplay Balancing
- `PERFORMANCE_RULES.do.js`: Optimization Guidelines
- `CURRENT_STATE.do.js`: Development Status
- `AI_MEMORY.do.js`: AI Context & Consistency

This ensures that the project remains consistent, performant, and scalable across all development phases.

# 🚀 IMPORTANT DEVELOPMENT RULES
To maintain premium mobile quality, all development must follow these rules:
1. **Project-Docs is the Brain**: Always read and update `/project-docs` before and after coding.
2. **Android Physical Testing is Mandatory**: Use `flutter run --release` on a real Android device for performance validation.
3. **No Chrome-First Development**: Chrome is only for minor debugging; focus on Android rendering and touch response.
4. **Pre-Git Check**: Verify FPS stability, zero touch lag, and small APK size before any Git commit.
5. **Clean Architecture**: Follow the established modular patterns in the `/lib` folder.

## 🌟 New in Phase 2
- **Modern Analog Joystick**: Smooth 360° movement with natural acceleration and deceleration.
- **Micro-Animations**: Expressive snake with tongue action and eye blinking.
- **Game Feel (Juiciness)**: 
    - **Camera Feedback**: Viewfinder shake and zoom effects on successful hunts.
    - **Floating Scores**: Real-time visual feedback for points earned.
    - **Elastic UI**: Level-up and combo indicators with bouncy animations.
- **Advanced AI**: 
    - **Panic Mode**: Prey animals react differently when the snake is within their detection radius.
    - **Unique Patterns**: Rabbits zig-zag, Frogs jump, and Rats run straight.
- **Level Progression**: 3 levels of increasing difficulty with time bonuses and speed multipliers.
- **Audio Service**: Dedicated system for compressed SFX and BGM (ready for assets).
- **Settings**: Modern modal for toggling sound and music.

## 🏗️ Technical Highlights
- **Prey Pooling**: Object reuse system for animals to minimize memory allocations.
- **Adaptive Icons**: Configured Android adaptive icon support for a premium Play Store look.
- **State Management**: Optimized Provider-based state for zero-lag HUD updates.
- **Clean Architecture**: Modular structure maintained for scalability.

## 🕹️ Controls
- **Virtual Joystick**: Use the semi-transparent joystick on the bottom-left to move.
- **Settings**: Tap the settings button on the main menu to toggle audio.

## 🚀 Optimization Roadmap
- [x] Object Pooling
- [x] SpriteAtlas Ready
- [x] Low Repaint Boundary
- [ ] Custom Sprite Sheet Integration
- [ ] Release Mode Performance Profiling

---
*Developed for a premium casual mobile gaming experience.*