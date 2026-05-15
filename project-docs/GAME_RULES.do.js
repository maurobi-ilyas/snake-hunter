/**
 * GAME_RULES.do.js - Game Mechanics and Rules
 * Project: SNAKE HUNTER
 */

const GameRules = {
  player: {
    baseSpeed: 200,
    speedMultiplierPerLevel: 1.1,
    growthPerEat: 0.1, // Visual growth or length
  },
  prey: {
    spawnInterval: 2.0, // seconds
    maxPreyOnScreen: 10,
    fleeDistance: 150,
    fleeSpeedMultiplier: 1.5,
  },
  scoring: {
    rat: 100,
    bird: 200,
    rabbit: 300,
    frog: 400,
    comboWindow: 3.0, // seconds
  },
  levels: {
    pointsToNextLevel: 1000,
    maxLevel: 10,
  }
};

module.exports = GameRules;
