# 🐍 SNAKE HUNTER - X10THINK ENTERPRISE PRODUCTION

An elite, high-performance, and enterprise-grade Flutter game pipeline.

## 🏛️ ENTERPRISE ARCHITECTURE
"SNAKE HUNTER" is built on a **Modular Engine Architecture**, separating specialized systems for maximum scalability and maintainability.
- **Rendering Engine**: Optimized sprite batching and smart rendering (View-frustum culling).
- **AI Engine**: Modular state machines with adaptive update frequency for distant entities.
- **Physics Engine**: Lightweight spatial partitioning (Collision Grid) for extreme CPU efficiency.
- **Audio Engine**: Decoupled SFX/BGM managers with optimized caching.
- **Save Engine**: Enterprise-grade persistence with anti-corruption and auto-save recovery.

## 🧠 THE MASTER BRAIN SYSTEM (/project-docs)
The `/project-docs` directory serves as the **Central Intelligence Engine**, ensuring architectural integrity across the entire development lifecycle.
- **SRS.do.js**: Enterprise requirements and scalability roadmap.
- **FEATURE_TRACKER.do.js**: Real-time monitoring of modular system status.
- **PERFORMANCE_RULES.do.js**: Hardware-specific metrics and optimization thresholds.
- **AI_MEMORY.do.js**: Production rules and historical context for the X10THINK engine.

## 🚀 ANTI-LAG & PERFORMANCE STRATEGY
We target a **Locked 60 FPS** on real Android hardware.
- **Global Anti-Lag**: Real-time FPS monitoring and performance warning system.
- **Smart Rendering**: Intelligent culling and adaptive AI logic to minimize GPU/CPU overhead.
- **Object Pooling**: Mandatory for all high-frequency entities (Animals, Particles).
- **Thermal Hardening**: Capped logic loops and efficient memory management to prevent overheating.

## 🛠️ PRODUCTION PIPELINE
1. **Android-First**: Mandatory physical device validation using `flutter run --release`.
2. **Hardened Save**: Auto-save at critical milestones with robust recovery logic.
3. **Atomic Commits**: Strict version control discipline with documentation synchronization.
4. **Fault Tolerance**: Null-safe, crash-preventative codebase designed for long-term support.

---
*Enterprise-grade casual gaming, redefined with Flutter.*