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

  static Future<void> playMenuMusic() async {
    try {
      await bgPlayer.setReleaseMode(ReleaseMode.loop);
      await bgPlayer.play(AssetSource('audio/menu_music.mpeg'), volume: 0.3);
    } catch (e) {
      print('Error playing menu music: $e');
    }
  }

  static Future<void> playGameMusic() async {
    try {
      await bgPlayer.setReleaseMode(ReleaseMode.loop);
      await bgPlayer.play(AssetSource('audio/game_music.mpeg'), volume: 0.25);
    } catch (e) {
      print('Error playing game music: $e');
    }
  }

  static Future<void> stopMusic() async {
    await bgPlayer.stop();
  }
}
