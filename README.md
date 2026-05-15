# 🐍 SNAKE HUNTER - X10THINK FULL PRODUCTION ENGINE

A high-performance, scalable, and addictive Flutter game built with the **Flame Engine**. 

## 🧠 PROJECT ARCHITECTURE & BRAIN SYSTEM
This project follows a **Senior-level Mobile Game Architecture**. The folder `/project-docs` acts as the **Central Intelligence**, ensuring architectural consistency and performance optimization.

### Core Brain Documents:
- **SRS.do.js**: Scalable requirements for future expansions (skins, maps).
- **GAME_RULES.do.js**: Balanced gameplay mechanics and progression logic.
- **PERFORMANCE_RULES.do.js**: Android-first optimization guidelines and mobile metrics.
- **AI_MEMORY.do.js**: Context and execution rules for the X10THINK production engine.

## 🚀 PERFORMANCE PHILOSOPHY
We prioritize **Android Physical Performance** above all.
- **Impeller Enabled**: Utilizing Vulkan/OpenGLES for high-frame-rate rendering.
- **60 FPS Target**: Verified on low-end hardware (Redmi Note 8).
- **Lightweight APK**: < 20MB per ABI via tree-shaking and resource optimization.
- **Efficient Memory**: Object pooling and picture caching for zero-stutter gameplay.

## 🕹️ ADVANCED GAME SYSTEMS
- **Scalable Skin System**: Foundation for custom snake aesthetics.
- **Dynamic AI**: Reactive animal patterns (Rat, Rabbit, Frog) with panic states.
- **Modern Control**: Precision analog joystick for satisfying 360° movement.
- **Juicy Game Feel**: Camera shake, floating scores, and elastic UI feedback.

## 🛠️ DEVELOPMENT RULES
1. **Android-First**: Mandatory validation on physical hardware using `flutter run --release`.
2. **Brain Synchronization**: Every feature must be documented in `/project-docs` before implementation.
3. **Scalable Design**: Code is built to support future missions, achievements, and online features.
4. **Pre-Git Validation**: Continuous monitoring of FPS, RAM, and thermal metrics.

---
*Built for the next generation of casual mobile gaming.*