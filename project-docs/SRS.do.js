/**
 * SRS.do.js - Software Requirements Specification (Phase 2 Update)
 * Project: SNAKE HUNTER
 */

const SRS = {
  gameplayLoop: "Player controls snake via modern analog joystick -> hunt prey -> prey flee with unique AI patterns -> catch/eat -> gain score & time -> level up.",
  snakeBehavior: {
    movement: "Smooth analog-style control with natural acceleration. Body following logic optimized for segments.",
    animations: ["idle", "moving", "eating", "tongueAction", "eyeBlinking"],
    visuals: "Dynamic scaling, expressive animations, smooth segment transitions."
  },
  animalAI: {
    states: ["idle", "wandering", "panic", "escaping"],
    fleeLogic: {
      detectionRadius: "Varies per animal (Rabbit: 200, Rat: 150)",
      patterns: {
        rat: "Direct escape",
        rabbit: "Zig-zag escape",
        frog: "Burst jump escape"
      }
    }
  },
  levelProgression: {
    level1: "Tutorial feel, slow animals, clear map.",
    level2: "Increased speed, minor obstacles.",
    level3: "Fast paced, multiple rare prey, score multiplier 2x."
  },
  optimization: {
    techniques: ["Object Pooling", "Sprite Atlas", "Low-cost collision", "Manual paint caching"],
    performanceTarget: "Solid 60 FPS on 2GB RAM devices."
  },
  gameFeel: {
    juiciness: ["Camera Shake", "Floating Scores", "Elastic UI Animations", "Particle Bursts"],
    feedback: "Rewarding haptic (visual) feedback on every successful hunt."
  }
};

module.exports = SRS;
