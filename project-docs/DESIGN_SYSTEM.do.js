/**
 * DESIGN_SYSTEM.do.js - X10THINK Visual Identity System
 * Snake Hunter — Premium Casual Mobile Game
 * Last Updated: 2026-05-16
 */

const DesignSystem = {
  identity: {
    name: "Snake Hunter",
    genre: "Premium Casual Mobile Game",
    visualStyle: "Modern Cartoon",
    targetVibe: ["lively", "colorful", "premium", "child-friendly", "polished"]
  },

  colorPalette: {
    primary: {
      emerald: "0xFF2ECC71",
      teal: "0xFF1ABC9C",
      gold: "0xFFFFD32A"
    },
    environment: {
      skyPastel: "0xFFC5E1A5",
      grassLight: "0xFFA5D6A7",
      grassMid: "0xFF81C784",
      grassDark: "0xFF66BB6A"
    },
    accents: {
      flowerRed: "0xFFFF8A80",
      flowerYellow: "0xFFFFF176",
      flowerPink: "0xFFF48FB1",
      mushroomCap: "0xFFFF8A80"
    }
  },

  snakeDesign: {
    style: "Expressive cartoon mascot",
    features: {
      head: "Glossy emerald with soft glow",
      eyes: "Large with pupils following movement direction",
      tongue: "Animated flick with timing",
      body: "Smooth segmented with wave motion",
      expressions: ["smile", "happy blush", "surprised O", "eating reaction"]
    },
    animations: ["sway", "squash-stretch", "blink", "tongue-flick", "happy blush"]
  },

  environmentLayers: {
    background: "Sky gradient with floating bubbles",
    midground: "Decorative flowers, mushrooms, bushes, rocks",
    foreground: "Grass blades with wind sway, floating leaves",
    ui: "Floating HUD with glassmorphism"
  },

  preyAnimals: {
    types: {
      mouse: { speed: 0.5, score: 100, escapeChance: 0.6 },
      rabbit: { speed: 0.7, score: 200, escapeChance: 0.7 },
      frog: { speed: 0.4, score: 150, escapeChance: 0.5 },
      bird: { speed: 0.9, score: 300, escapeChance: 0.8 },
      chick: { speed: 0.6, score: 150, escapeChance: 0.65 }
    },
    behaviors: {
      wandering: "Random movement with low speed",
      escaping: "Panic animation, high speed, shake effect",
      escapeSuccess: "Taunt animation with wink and tongue"
    }
  },

  funFactorSystem: {
    hunting: {
      biteRadius: 25,
      requirement: "Must approach closely enough",
      escapeWindow: "Animals can escape if not caught in time"
    },
    combo: {
      window: 2.5,
      multiplier: 0.15,
      maxMultiplier: 3.0
    },
    feedback: {
      onEat: ["bounce", "sparkle", "scorePopup", "cameraShake", "happyExpression"],
      onEscape: ["tauntAnimation", "wink", "tongueOut"]
    }
  },

  updatedAt: "2026-05-16"
};

module.exports = DesignSystem;