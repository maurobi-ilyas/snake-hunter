/**
 * GAME_RULES.do.js - Game Mechanics and Balancing (Phase 2)
 * Project: SNAKE HUNTER
 */

const GameRules = {
  player: {
    baseSpeed: 220,
    acceleration: 400,
    maxLength: 50,
    growthRate: 1, // segments per eat
  },
  prey: {
    rat: { speed: 100, score: 100, timeBonus: 2, spawnWeight: 0.6 },
    rabbit: { speed: 180, score: 300, timeBonus: 5, spawnWeight: 0.3 },
    frog: { speed: 120, score: 500, timeBonus: 10, spawnWeight: 0.1 },
  },
  levels: {
    1: { targetScore: 1000, animalSpeedMult: 1.0, spawnInterval: 2.0 },
    2: { targetScore: 3000, animalSpeedMult: 1.2, spawnInterval: 1.5 },
    3: { targetScore: 6000, animalSpeedMult: 1.5, spawnInterval: 1.0 },
  },
  combo: {
    window: 3.0, // seconds
    multiplierPerStreak: 0.1, // +10% per consecutive catch
  }
};

module.exports = GameRules;
