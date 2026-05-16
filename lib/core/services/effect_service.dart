// ignore_for_file: avoid_print
import 'package:vibration/vibration.dart';

class EffectService {
  static bool _hasVibrator = false;
  static bool _checked = false;

  static Future<void> _ensureChecked() async {
    if (_checked) return;
    _hasVibrator = (await Vibration.hasVibrator()) ?? false;
    _checked = true;
  }

  /// Short buzz — on eat
  static Future<void> vibrateShort() async {
    await _ensureChecked();
    if (_hasVibrator) Vibration.vibrate(duration: 60);
  }

  /// Long buzz — on game over
  static Future<void> vibrateGameOver() async {
    await _ensureChecked();
    if (_hasVibrator) Vibration.vibrate(duration: 350);
  }

  /// Soft buzz — on boss hit
  static Future<void> vibrateBossHit() async {
    await _ensureChecked();
    if (_hasVibrator) Vibration.vibrate(duration: 120);
  }
}
