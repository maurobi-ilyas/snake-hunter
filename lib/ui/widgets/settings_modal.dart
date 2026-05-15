import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/game_state.dart';

class SettingsModal extends StatelessWidget {
  const SettingsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, state, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: GameStyles.glassmorphism.copyWith(
              color: Colors.black87.withOpacity(0.9),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'SETTINGS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 30),
                
                _SettingToggle(
                  label: 'SOUND',
                  value: state.isSoundOn,
                  onChanged: (v) => state.toggleSound(),
                ),
                
                const SizedBox(height: 15),
                
                _SettingToggle(
                  label: 'MUSIC',
                  value: state.isMusicOn,
                  onChanged: (v) => state.toggleMusic(),
                ),
                
                const SizedBox(height: 30),
                
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GameColors.accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('CLOSE'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: GameColors.accent,
        ),
      ],
    );
  }
}
