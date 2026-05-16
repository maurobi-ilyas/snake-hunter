class PlayerModel {
  String playerName;
  int highScore;
  int coins;
  int level;

  PlayerModel({
    required this.playerName,
    required this.highScore,
    required this.coins,
    this.level = 1,
  });

  factory PlayerModel.fromMap(Map<String, dynamic> map) {
    return PlayerModel(
      playerName: map['playerName'] ?? 'Guest',
      highScore: map['score'] ?? 0,
      coins: map['coins'] ?? 0,
      level: map['level'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'playerName': playerName,
      'score': highScore,
      'coins': coins,
      'level': level,
    };
  }
}
