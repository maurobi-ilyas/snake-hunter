/**
 * PERFORMANCE_RULES.do.js - Optimization Guidelines
 * Project: SNAKE HUNTER
 */

const PerformanceRules = {
  maxAssetSizeMB: 5,
  targetFPS: 60,
  optimizationTechniques: [
    "SpriteAtlas for all textures",
    "Preload all assets on Splash Screen",
    "Object Pooling for prey and particles",
    "Avoid RepaintBoundary where not needed",
    "Minimize Widget rebuilds using const constructors",
    "Use BLoC or Provider for state to avoid global rebuilds"
  ],
  lowEndOptimization: {
    reduceParticleCount: true,
    disableComplexShaders: true,
    limitSimultaneousAnimations: 5
  }
};

module.exports = PerformanceRules;
