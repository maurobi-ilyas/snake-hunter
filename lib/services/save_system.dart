import 'dart:convert';
import 'dart:developer' as dev;
import 'package:shared_preferences/shared_preferences.dart';

class SaveData {
  final int highScore;
  final List<String> unlockedSkins;
  final bool isSoundOn;
  final bool isMusicOn;
  final int playerLevel;
  final List<String> completedMissions;

  SaveData({
    this.highScore = 0,
    this.unlockedSkins = const ['default'],
    this.isSoundOn = true,
    this.isMusicOn = true,
    this.playerLevel = 1,
    this.completedMissions = const [],
  });

  Map<String, dynamic> toJson() => {
    'highScore': highScore,
    'unlockedSkins': unlockedSkins,
    'isSoundOn': isSoundOn,
    'isMusicOn': isMusicOn,
    'playerLevel': playerLevel,
    'completedMissions': completedMissions,
  };

  factory SaveData.fromJson(Map<String, dynamic> json) {
    try {
      return SaveData(
        highScore: (json['highScore'] is int && (json['highScore'] as int) >= 0) ? json['highScore'] : 0,
        unlockedSkins: List<String>.from(json['unlockedSkins'] ?? ['default']),
        isSoundOn: json['isSoundOn'] ?? true,
        isMusicOn: json['isMusicOn'] ?? true,
        playerLevel: (json['playerLevel'] is int && (json['playerLevel'] as int) >= 1) ? json['playerLevel'] : 1,
        completedMissions: List<String>.from(json['completedMissions'] ?? []),
      );
    } catch (e) {
      dev.log('SaveData Recovery: Corrupt sub-keys detected, returning partial defaults', name: 'SaveSystem');
      return SaveData();
    }
  }
}

class SaveSystem {
  static const String _saveKey = 'snake_hunter_save_v1';

  static Future<void> save(SaveData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(data.toJson());
      await prefs.setString(_saveKey, jsonString);
    } catch (e) {
      dev.log('SAVE ERROR: Failed to persist data: $e', name: 'SaveSystem');
    }
  }

  static Future<SaveData> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_saveKey);
      if (jsonString == null) return SaveData();
      return SaveData.fromJson(jsonDecode(jsonString));
    } catch (e) {
      dev.log('LOAD ERROR: Save data corrupt, using defaults: $e', name: 'SaveSystem');
      return SaveData();
    }
  }
}
