/**
 * AI_MEMORY.do.js - Context for AI development
 * Project: SNAKE HUNTER
 */

const AIMemory = {
  mode: "X10THINK FULL PRODUCTION ENGINE",
  philosophy: "Senior Mobile Game Engineer mindset. Focus on scalability, maintainability, and Android-first performance.",
  styleGuide: "Modern cartoon, pastel, premium glassmorphism UI.",
  namingConvention: "PascalCase for classes, camelCase for variables/methods.",
  importantPatterns: [
    "Flame Game loop for logic",
    "Provider for global state",
    "Modular components for animals",
    "Android-First rendering and testing",
    "Release-mode performance verification"
  ],
  mobileTestingRules: {
    targetFPS: 60,
    priority: "Android Physical Device",
    metrics: ["Touch Latency", "Thermal Performance", "RAM Efficiency"],
    preGitCheck: [
      "flutter run --release on physical device",
      "Verify stable 60 FPS",
      "Check zero touch lag",
      "Validate APK size < 20MB per ABI"
    ]
  },
  previousIssues: "1. Removed tap-to-move logic to resolve compilation error. 2. Fixed adaptive icon resource linking. 3. Restored accidentally removed _isSoundOn variable in GameState during X10THINK system integration."
};

module.exports = AIMemory;
