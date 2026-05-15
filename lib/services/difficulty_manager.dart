import '../services/game_state.dart';

class DifficultyManager {
  static double getSpawnInterval(int level) {
    // Faster spawning as level increases
    return (2.0 - (level * 0.1)).clamp(0.5, 2.0);
  }

  static double getAnimalSpeedMultiplier(int level) {
    // Animals get faster
    return (1.0 + (level * 0.05)).clamp(1.0, 2.0);
  }

  static int getScoreMultiplier(int level) {
    // Higher score for higher levels
    return level;
  }
}
