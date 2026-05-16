import 'package:flutter/material.dart';

import '../core/services/local_storage_service.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  int _highScore = 0;
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final hs = await LocalStorageService.getHighScore();
    final c = LocalStorageService.getCoins();
    setState(() {
      _highScore = hs;
      _coins = c;
    });
  }

  List<Map<String, dynamic>> get _achievements => [
    {
      'icon': Icons.restaurant,
      'title': 'First Bite',
      'desc': 'Eat your first food',
      'reward': '10 Coins',
      'done': _highScore >= 1,
      'color': Colors.greenAccent,
    },
    {
      'icon': Icons.emoji_events,
      'title': 'Snake Rookie',
      'desc': 'Reach score 10',
      'reward': '20 Coins',
      'done': _highScore >= 10,
      'color': Colors.blueAccent,
    },
    {
      'icon': Icons.local_fire_department,
      'title': 'Snake Master',
      'desc': 'Reach score 25',
      'reward': '50 Coins',
      'done': _highScore >= 25,
      'color': Colors.orangeAccent,
    },
    {
      'icon': Icons.speed,
      'title': 'Speed Demon',
      'desc': 'Reach score 50',
      'reward': '100 Coins',
      'done': _highScore >= 50,
      'color': Colors.redAccent,
    },
    {
      'icon': Icons.monetization_on,
      'title': 'Rich Player',
      'desc': 'Collect 200 coins total',
      'reward': 'Purple Shadow skin',
      'done': _coins >= 200,
      'color': Colors.purpleAccent,
    },
    {
      'icon': Icons.star,
      'title': 'Legend',
      'desc': 'Reach score 100',
      'reward': 'Gold Legend skin',
      'done': _highScore >= 100,
      'color': Colors.amber,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final unlocked = _achievements.where((a) => a['done'] as bool).length;

    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      appBar: AppBar(
        title: const Text('ACHIEVEMENTS'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF0D1117),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Unlocked',
                        style: TextStyle(color: Colors.white38, fontSize: 11)),
                    Text('$unlocked / ${_achievements.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(
                  width: 120,
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: unlocked / _achievements.length,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF00FF9D)),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(unlocked / _achievements.length * 100).round()}%',
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Achievement list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _achievements.length,
              itemBuilder: (_, i) {
                final a = _achievements[i];
                final done = a['done'] as bool;
                final color = a['color'] as Color;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF0D1117),
                    border: Border.all(
                      color: done ? color.withOpacity(0.4) : Colors.white10,
                    ),
                    boxShadow: done
                        ? [BoxShadow(color: color.withOpacity(0.08), blurRadius: 10)]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done ? color.withOpacity(0.15) : Colors.white10,
                          border: Border.all(
                            color: done ? color : Colors.white12,
                          ),
                        ),
                        child: Icon(
                          done ? a['icon'] as IconData : Icons.lock_outline,
                          color: done ? color : Colors.white24,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a['title'] as String,
                                style: TextStyle(
                                    color: done ? Colors.white : Colors.white38,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                            Text(a['desc'] as String,
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text('🎁 ${a['reward']}',
                                style: TextStyle(
                                    color: done ? color : Colors.white24,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      if (done)
                        const Icon(Icons.check_circle,
                            color: Color(0xFF00FF9D), size: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
