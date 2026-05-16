/**
 * GAME_RULES.do.js - Game Mechanics and Balancing (X10THINK Hunting System)
 * Project: SNAKE HUNTER
 */

const GameRules = {
  levelProgression: {
    baseExp: 2000,
    difficultyMultiplier: 1.2,
    maxLevel: 100
  },
  missionSystem: {
    types: ["Score-based", "Hunt-based", "Time-based"],
    rewards: ["Skins", "Titles"]
  },
  player: {
    baseSpeed: 220,
    acceleration: 400,
    maxLength: 50,
    growthRate: 1, // segments per eat
    biteRadius: 25 // distance required for successful catch
  },
  hunting: {
    // New hunting mechanics
    approachSuccess: "Must reach bite radius (25px) to catch",
    escapeSuccess: "Animals escape if snake gets too close but doesn't catch",
    comboWindow: 2.5, // seconds to maintain combo
    comboMultiplier: 0.15 // +15% per consecutive catch
  },
  animals: {
    // Updated animal behavior
    types: {
      mouse: { 
        emoji: "🐭", 
        speed: 0.5, 
        score: 100, 
        color: 0xFFA1887F,
        escapeChance: 0.6 
      },
      rabbit: { 
        emoji: "🐰", 
        speed: 0.7, 
        score: 200, 
        color: 0xFFE0E0E0,
        escapeChance: 0.7 
      },
      frog: { 
        emoji: "🐸", 
        speed: 0.4, 
        score: 150, 
        color: 0xFF9CCC65,
        escapeChance: 0.5 
      },
      bird: { 
        emoji: "🐦", 
        speed: 0.9, 
        score: 300, 
        color: 0xFFB3E5FC,
        escapeChance: 0.8 
      },
      chick: { 
        emoji: "🐥", 
        speed: 0.6, 
        score: 150, 
        color: 0xFFFFF9C4,
        escapeChance: 0.65 
      }
    }
  },
  snake: {
    // Snake expressions
    happyDuration: 0.8, // seconds after eating
    blinkInterval: [3.0, 7.0], // random range
    tongueInterval: [2.0, 4.0] // random range when out
  },
  levels: {
    1: { targetScore: 1000, animalSpeedMult: 1.0, spawnInterval: 2.0 },
    2: { targetScore: 3000, animalSpeedMult: 1.2, spawnInterval: 1.5 },
    3: { targetScore: 6000, animalSpeedMult: 1.5, spawnInterval: 1.0 },
    4: { targetScore: 10000, animalSpeedMult: 1.8, spawnInterval: 0.8 },
    5: { targetScore: 15000, animalSpeedMult: 2.0, spawnInterval: 0.6 }
  },
  combo: {
    window: 2.5, // seconds - faster than before
    multiplierPerStreak: 0.15, // +15% per consecutive catch
    maxMultiplier: 3.0 // cap at 3x
  },
  feedback: {
    // Eating feedback system
    bounceStrength: 1.25,
    cameraShake: { intensity: 5, duration: 0.04, repeats: 3 },
    particleCount: 10
  }
};

module.exports = GameRules;