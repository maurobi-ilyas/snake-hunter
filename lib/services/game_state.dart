import 'package:flutter/material.dart';
import 'leaderboard_service.dart';
import '../core/skin_system.dart';
import '../core/mission_system.dart';
import 'save_system.dart';

enum GameStatus { menu, playing, paused, gameOver }

class GameState with ChangeNotifier {
  int _score = 0;
  int _highScore = 0;
  GameStatus _status = GameStatus.menu;
  int _level = 1;
  int _combo = 0;
  DateTime? _lastCatchTime;
  int _timeLeft = 60;
  bool _isSoundOn = true;
  bool _isMusicOn = true;
  SnakeSkin _currentSkin = SnakeSkin.defaultSkin;
  final List<Mission> _missions = [
    Mission(id: 'hunt_10', title: 'Novice Hunter', description: 'Catch 10 animals', goalValue: 10),
    Mission(id: 'score_5000', title: 'High Scorer', description: 'Reach 5000 points', goalValue: 5000),
  ];

  int get score => _score;
  int get highScore => _highScore;
  GameStatus get status => _status;
  int get level => _level;
  int get combo => _combo;
  int get timeLeft => _timeLeft;
  bool get isSoundOn => _isSoundOn;
  bool get isMusicOn => _isMusicOn;
  SnakeSkin get currentSkin => _currentSkin;
  List<Mission> get missions => _missions;

  void addScore(int points) {
    final now = DateTime.now();
    if (_lastCatchTime != null && now.difference(_lastCatchTime!).inSeconds < 3) {
      _combo++;
    } else {
      _combo = 1;
    }
    _lastCatchTime = now;

    _score += (points * (1 + (_combo * 0.1))).toInt();
    
    // Update Missions
    for (var m in _missions) {
      if (m.id == 'hunt_10') m.update(1);
      if (m.id == 'score_5000') m.update(points);
    }

    // Level Up Check
    int newLevel = (_score / 2000).floor() + 1;
    if (newLevel > _level) {
      _level = newLevel;
      _timeLeft += 10; // Bonus time on level up
      _autoSave();
    }

    if (_score > _highScore) {
      _highScore = _score;
      _autoSave();
    }
    notifyListeners();
  }

  void _autoSave() {
    SaveSystem.save(SaveData(
      highScore: _highScore,
      isSoundOn: _isSoundOn,
      isMusicOn: _isMusicOn,
      playerLevel: _level,
    ));
  }

  void setStatus(GameStatus status) {
    _status = status;
    notifyListeners();
  }

  void resetGame() {
    _score = 0;
    _level = 1;
    _timeLeft = 60;
    _status = GameStatus.playing;
    notifyListeners();
  }

  void tick() {
    if (_status == GameStatus.playing) {
      _timeLeft--;
      if (_timeLeft <= 0) {
        _status = GameStatus.gameOver;
        saveCurrentScore();
      }
      notifyListeners();
    }
  }

  void addTime(int seconds) {
    _timeLeft += seconds;
    notifyListeners();
  }

  void nextLevel() {
    _level++;
    notifyListeners();
  }

  void toggleSound() {
    _isSoundOn = !_isSoundOn;
    notifyListeners();
  }

  void toggleMusic() {
    _isMusicOn = !_isMusicOn;
    notifyListeners();
  }

  void setSkin(SnakeSkin skin) {
    _currentSkin = skin;
    notifyListeners();
  }

  Future<List<int>> loadHighScores() async {
    return await LeaderboardService.getHighScores();
  }

  void saveCurrentScore() {
    LeaderboardService.saveScore(_score);
  }
}
