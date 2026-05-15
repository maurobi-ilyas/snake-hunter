import 'package:flame_audio/flame_audio.dart';
import '../services/game_state.dart';

class AudioService {
  static Future<void> init() async {
    await FlameAudio.audioCache.loadAll([
      'eat.mp3',
      'combo.mp3',
      'panic.mp3',
      'click.mp3',
      'bgm.mp3',
    ]);
  }

  static void playSfx(String name, GameState state) {
    if (state.isSoundOn) {
      FlameAudio.play(name);
    }
  }

  static void playBgm(GameState state) {
    if (state.isMusicOn) {
      FlameAudio.bgm.play('bgm.mp3');
    }
  }

  static void stopBgm() {
    FlameAudio.bgm.stop();
  }
}
