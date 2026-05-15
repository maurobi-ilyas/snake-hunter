import 'package:flutter/material.dart';
import 'leaderboard_service.dart';

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

  int get score => _score;
  int get highScore => _highScore;
  GameStatus get status => _status;
  int get level => _level;
  int get combo => _combo;
  int get timeLeft => _timeLeft;
  bool get isSoundOn => _isSoundOn;
  bool get isMusicOn => _isMusicOn;

  void addScore(int points) {
    final now = DateTime.now();
    if (_lastCatchTime != null && now.difference(_lastCatchTime!).inSeconds < 3) {
      _combo++;
    } else {
      _combo = 1;
    }
    _lastCatchTime = now;

    _score += (points * (1 + (_combo * 0.1))).toInt();
    
    // Level Up Check
    int newLevel = (_score / 2000).floor() + 1;
    if (newLevel > _level) {
      _level = newLevel;
      _timeLeft += 10; // Bonus time on level up
    }

    if (_score > _highScore) {
      _highScore = _score;
    }
    notifyListeners();
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

  Future<List<int>> loadHighScores() async {
    return await LeaderboardService.getHighScores();
  }

  void saveCurrentScore() {
    LeaderboardService.saveScore(_score);
  }
}
