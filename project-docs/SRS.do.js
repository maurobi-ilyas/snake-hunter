/**
 * SRS.do.js - Software Requirements Specification
 * Project: SNAKE HUNTER
 */

const SRS = {
  gameplayLoop: "Player controls snake -> search for prey -> prey flee when approached -> catch/eat prey -> gain score -> progression (speed up).",
  snakeBehavior: {
    movement: "Smooth analog-style touch control. Flexible body following head path.",
    animations: ["idle", "moving", "eating", "speedBoost", "happy"],
    visuals: "Cute, modern cartoon style, expressive eyes."
  },
  animalAI: {
    states: ["idle", "wandering", "panic", "escaping", "hiding"],
    fleeLogic: "When snake distance < threshold, trigger panic animation and move away from snake position.",
    variants: ["rat", "chicken", "rabbit", "frog", "bird"]
  },
  scoringSystem: {
    baseScore: 100,
    comboMultiplier: "Increases with consecutive catches within short window.",
    bonuses: ["speed catch", "perfect movement"]
  },
  levelProgression: "Increasing speed of snake and animals, more obstacles, higher spawn rate of rare prey.",
  uiBehavior: {
    style: "Modern Glassmorphism, rounded corners, soft shadows, pastel colors.",
    screens: ["Splash", "MainMenu", "GameHUD", "Pause", "Settings", "Leaderboard", "GameOver"]
  },
  performanceRules: {
    fpsTarget: 60,
    maxAssetSize: "Small compressed assets (WebP/SVG)",
    optimization: ["Sprite Batching", "Object Pooling", "Lazy Loading"]
  },
  touchInteraction: "Responsive virtual joystick or direct touch following.",
  gameStateManagement: "Provider/ChangeNotifier for global state (score, settings, level)."
};

module.exports = SRS;
