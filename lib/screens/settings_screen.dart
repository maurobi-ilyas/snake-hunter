import 'package:flutter/material.dart';

import '../core/services/audio_service.dart';
import '../core/services/local_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _sound = true;
  bool _music = true;

  @override
  void initState() {
    super.initState();
    _sound = LocalStorageService.getSoundEnabled();
    _music = LocalStorageService.getMusicEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      appBar: AppBar(
        title: const Text('SETTINGS'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.volume_up_rounded,
              title: 'Sound Effects',
              subtitle: 'Eat, game over sounds',
              value: _sound,
              color: const Color(0xFF00FF9D),
              onChanged: (val) async {
                setState(() => _sound = val);
                await LocalStorageService.saveSoundEnabled(val);
              },
            ),

            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.music_note_rounded,
              title: 'Background Music',
              subtitle: 'Menu background music',
              value: _music,
              color: const Color(0xFF00BFFF),
              onChanged: (val) async {
                setState(() => _music = val);
                await LocalStorageService.saveMusicEnabled(val);
                if (val) {
                  AudioService.playBackgroundMusic();
                } else {
                  AudioService.stopMusic();
                }
              },
            ),

            const SizedBox(height: 32),

            // About section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
                color: const Color(0xFF0D1117),
              ),
              child: Column(
                children: [
                  const Icon(Icons.linear_scale_rounded, size: 36, color: Color(0xFF00FF9D)),
                  const SizedBox(height: 10),
                  const Text(
                    'SNAKE ESCAPE EVOLUTION',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v1.0.0',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF0D1117),
        border: Border.all(
          color: value ? color.withOpacity(0.4) : Colors.white10,
          width: 1,
        ),
        boxShadow: value
            ? [BoxShadow(color: color.withOpacity(0.08), blurRadius: 12)]
            : [],
      ),
      child: Row(
        children: [
          Icon(icon, color: value ? color : Colors.white38, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: value ? Colors.white : Colors.white60,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            activeTrackColor: color.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
