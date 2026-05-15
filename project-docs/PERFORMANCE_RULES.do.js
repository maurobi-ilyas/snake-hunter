/**
 * PERFORMANCE_RULES.do.js - Hardware limits and optimization targets
 * Project: SNAKE HUNTER
 */

const PerformanceRules = {
  targets: {
    flagship: "60 FPS (Locked)",
    midRange: "60 FPS (Stable)",
    lowEnd: "Stable Gameplay (45+ FPS)",
    thermalLimit: "42°C",
    maxRamUsage: "120MB (Enterprise Cap)"
  },
  optimizationApplied: {
    objectPooling: "Prey, Particles, Effects",
    spatialPartitioning: "Collision Grid Active",
    adaptiveQuality: "JuiceService Auto-Scaling",
    rendering: "Repaint Boundaries & Smart Culling",
    build: "R8 Minification & Resource Shrinking"
  },
  lowEndHardwareProfile: {
    particleMultiplier: 0.3,
    disableHeavyAnimations: true,
    simplifiedUIEffects: true
  }
};

module.exports = PerformanceRules;
