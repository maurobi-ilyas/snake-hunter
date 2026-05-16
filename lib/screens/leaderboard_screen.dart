import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/services/firestore_service.dart';
import '../core/services/local_storage_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _localHighScore = 0;
  int _localCoins = 0;
  String _playerName = 'Guest Player';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    final hs = await LocalStorageService.getHighScore();
    final coins = await LocalStorageService.getCoins();
    final name = await LocalStorageService.getPlayerName();
    if (mounted) {
      setState(() {
        _localHighScore = hs;
        _localCoins = coins;
        _playerName = name;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      appBar: AppBar(
        title: const Text('LEADERBOARD'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00FF9D),
          labelColor: const Color(0xFF00FF9D),
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(text: 'ONLINE'),
            Tab(text: 'MY STATS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OnlineLeaderboard(),
          _LocalStats(
            highScore: _localHighScore,
            coins: _localCoins,
            playerName: _playerName,
            onNameChanged: (name) async {
              await LocalStorageService.setPlayerName(name);
              setState(() => _playerName = name);
            },
          ),
        ],
      ),
    );
  }
}

class _OnlineLeaderboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Firebase not configured — show offline message immediately
    if (!FirestoreService.isAvailable) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 52, color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'Leaderboard online\nbelum dikonfigurasi',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 14, letterSpacing: 1, height: 1.6),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: const Text(
                'Tambahkan google-services.json\nke android/app/ untuk mengaktifkan',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white24, fontSize: 11),
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.leaderboardStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00FF9D)));
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.leaderboard, size: 48, color: Colors.white24),
                const SizedBox(height: 16),
                const Text('Belum ada skor.\nMainkan dulu!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 14)),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final name  = data['playerName'] ?? 'Guest';
            final score = data['score'] ?? 0;
            final level = data['level'] ?? 1;
            final coins = data['coins'] ?? 0;

            Color rankColor = Colors.white38;
            IconData rankIcon = Icons.star_border;
            if (index == 0)      { rankColor = Colors.amber;           rankIcon = Icons.emoji_events; }
            else if (index == 1) { rankColor = Colors.grey.shade300;   rankIcon = Icons.emoji_events; }
            else if (index == 2) { rankColor = Colors.brown.shade300;  rankIcon = Icons.emoji_events; }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF0D1117),
                border: Border.all(color: index < 3 ? rankColor.withOpacity(0.4) : Colors.white10, width: 1),
              ),
              child: Row(
                children: [
                  Icon(rankIcon, color: rankColor, size: 20),
                  const SizedBox(width: 12),
                  Text('#${index + 1}', style: TextStyle(color: rankColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('LV $level  •  🪙 $coins', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ),
                  Text('$score', style: const TextStyle(color: Color(0xFF00FF9D), fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _LocalStats extends StatelessWidget {
  final int highScore;
  final int coins;
  final String playerName;
  final Function(String) onNameChanged;

  const _LocalStats({
    required this.highScore,
    required this.coins,
    required this.playerName,
    required this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Player avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00FF9D), width: 2),
              color: const Color(0xFF0D1117),
            ),
            child: const Icon(Icons.person, size: 40, color: Color(0xFF00FF9D)),
          ),

          const SizedBox(height: 12),

          GestureDetector(
            onTap: () => _showNameDialog(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  playerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.edit, size: 14, color: Colors.white38),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.emoji_events,
                  label: 'HIGH SCORE',
                  value: '$highScore',
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.monetization_on,
                  label: 'TOTAL COINS',
                  value: '$coins',
                  color: Colors.orangeAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _StatCard(
            icon: Icons.info_outline,
            label: 'STATUS FIREBASE',
            value: 'Tambahkan google-services.json\nuntuk mengaktifkan leaderboard online',
            color: Colors.blueAccent,
            isMultiline: true,
          ),
        ],
      ),
    );
  }

  void _showNameDialog(BuildContext context) {
    final controller = TextEditingController(text: playerName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1117),
        title: const Text('Ganti Nama', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nama kamu...',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00FF9D)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onNameChanged(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan', style: TextStyle(color: Color(0xFF00FF9D))),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isMultiline;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF0D1117),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isMultiline ? 11 : 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
