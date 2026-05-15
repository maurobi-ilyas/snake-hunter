import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardService {
  static const String _key = 'high_scores';

  static Future<List<int>> getHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final scores = prefs.getStringList(_key) ?? [];
    return scores.map(int.parse).toList()..sort((a, b) => b.compareTo(a));
  }

  static Future<void> saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final scores = prefs.getStringList(_key) ?? [];
    final intScores = scores.map(int.parse).toList();
    
    if (!intScores.contains(score)) {
      intScores.add(score);
      intScores.sort((a, b) => b.compareTo(a));
      
      // Keep only top 10
      final topScores = intScores.take(10).map((e) => e.toString()).toList();
      await prefs.setStringList(_key, topScores);
    }
  }
}
