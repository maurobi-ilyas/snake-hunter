/**
 * AI_MEMORY.do.js - Context for AI development
 * Project: SNAKE HUNTER
 */

const AIMemory = {
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
  previousIssues: "1. Removed tap-to-move logic to resolve compilation error after switching to joystick-only controls. 2. Created missing assets/images and assets/audio directories to fix build failure. 3. Fixed Android resource linking error by creating missing ic_launcher_foreground.xml for adaptive icons."
};

module.exports = AIMemory;
