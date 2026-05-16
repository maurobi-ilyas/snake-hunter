import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer bgPlayer = AudioPlayer();
  static final AudioPlayer sfxPlayer = AudioPlayer();

  static Future<void> playEat() async {
    try {
      await sfxPlayer.play(AssetSource('audio/eat.wav'));
    } catch (e) {
      print('Error playing eat sound: $e');
    }
  }

  static Future<void> playGameOver() async {
    try {
      await sfxPlayer.play(AssetSource('audio/gameover.wav'));
    } catch (e) {
      print('Error playing gameover sound: $e');
    }
  }

  static Future<void> playBackgroundMusic() async {
    try {
      await bgPlayer.setReleaseMode(ReleaseMode.loop);
      await bgPlayer.play(AssetSource('audio/bg.mp3'), volume: 0.3);
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  static Future<void> stopMusic() async {
    await bgPlayer.stop();
  }
}
