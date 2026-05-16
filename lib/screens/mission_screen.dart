import 'package:flutter/material.dart';

import '../core/services/local_storage_service.dart';
import '../game/models/mission_model.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  int _highScore = 0;
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final hs = await LocalStorageService.getHighScore();
    final c = LocalStorageService.getCoins();
    setState(() { _highScore = hs; _coins = c; });
  }

  List<MissionModel> get _missions => [
    MissionModel(id: 'm1', title: 'First Blood',    description: 'Reach score 1',        reward: '10 Coins',   completed: _highScore >= 1),
    MissionModel(id: 'm2', title: 'Score Runner',   description: 'Reach score 10',       reward: '25 Coins',   completed: _highScore >= 10),
    MissionModel(id: 'm3', title: 'Stage Climber',  description: 'Reach Stage 2 (score 15+)', reward: '50 Coins', completed: _highScore >= 15),
    MissionModel(id: 'm4', title: 'Boss Slayer',    description: 'Survive to score 30+', reward: '100 Coins',  completed: _highScore >= 30),
    MissionModel(id: 'm5', title: 'AI Core Master', description: 'Reach Stage 4 (score 45+)', reward: '200 Coins', completed: _highScore >= 45),
    MissionModel(id: 'm6', title: 'Coin Hoarder',   description: 'Collect 100+ coins',   reward: 'Blue Plasma skin', completed: _coins >= 100),
    MissionModel(id: 'm7', title: 'Speed Freak',    description: 'Reach score 50',       reward: 'Gold Legend skin', completed: _highScore >= 50),
  ];

  @override
  Widget build(BuildContext context) {
    final missions = _missions;
    final done = missions.where((m) => m.completed).length;

    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      appBar: AppBar(
        title: const Text('MISSIONS'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF0D1117),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.flag_rounded, color: Colors.cyanAccent, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$done / ${missions.length} Missions Completed',
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: done / missions.length,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(Colors.cyanAccent),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(done / missions.length * 100).round()}%',
                  style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Mission list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: missions.length,
              itemBuilder: (_, i) {
                final m = missions[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF0D1117),
                    border: Border.all(
                      color: m.completed ? Colors.cyanAccent.withOpacity(0.4) : Colors.white10,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: m.completed ? Colors.cyanAccent.withOpacity(0.15) : Colors.white10,
                          border: Border.all(color: m.completed ? Colors.cyanAccent : Colors.white24),
                        ),
                        child: Icon(
                          m.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: m.completed ? Colors.cyanAccent : Colors.white24,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.title,
                                style: TextStyle(
                                    color: m.completed ? Colors.white : Colors.white54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                            Text(m.description,
                                style: const TextStyle(color: Colors.white38, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text('🎁 ${m.reward}',
                                style: TextStyle(
                                    color: m.completed ? Colors.cyanAccent : Colors.white24,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
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
