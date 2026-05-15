import 'dart:convert';
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

  factory SaveData.fromJson(Map<String, dynamic> json) => SaveData(
    highScore: json['highScore'] ?? 0,
    unlockedSkins: List<String>.from(json['unlockedSkins'] ?? ['default']),
    isSoundOn: json['isSoundOn'] ?? true,
    isMusicOn: json['isMusicOn'] ?? true,
    playerLevel: json['playerLevel'] ?? 1,
    completedMissions: List<String>.from(json['completedMissions'] ?? []),
  );
}

class SaveSystem {
  static const String _saveKey = 'snake_hunter_save_v1';

  static Future<void> save(SaveData data) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(data.toJson());
    await prefs.setString(_saveKey, jsonString);
  }

  static Future<SaveData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_saveKey);
    if (jsonString == null) return SaveData();
    try {
      return SaveData.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return SaveData();
    }
  }
}
