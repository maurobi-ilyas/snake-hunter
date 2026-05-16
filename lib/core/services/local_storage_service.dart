// ignore_for_file: avoid_print
import 'package:shared_preferences/shared_preferences.dart';

/// Offline-first storage using SharedPreferences.
/// Call [init()] once at startup to enable synchronous getters.
class LocalStorageService {
  static SharedPreferences? _prefs;

  static const _keyHighScore = 'high_score';
  static const _keyCoins = 'total_coins';
  static const _keyPlayerName = 'player_name';
  static const _keySkin = 'selected_skin';
  static const _keySound = 'sound_enabled';
  static const _keyMusic = 'music_enabled';
  static const _keyLastReward = 'last_reward_date';
  static const _keyDifficulty = 'game_difficulty';

  /// Must be called once in main() before runApp.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── HIGH SCORE ────────────────────────────────────────────

  static Future<int> getHighScore() async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    return p.getInt(_keyHighScore) ?? 0;
  }

  static Future<void> saveHighScore(int score) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    final current = p.getInt(_keyHighScore) ?? 0;
    if (score > current) await p.setInt(_keyHighScore, score);
  }

  // ── COINS ────────────────────────────────────────────────

  static int getCoins() {
    return _prefs?.getInt(_keyCoins) ?? 0;
  }

  static Future<void> saveCoins(int amount) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setInt(_keyCoins, amount);
    _prefs = p;
  }

  static Future<void> addCoins(int amount) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    final current = p.getInt(_keyCoins) ?? 0;
    await p.setInt(_keyCoins, current + amount);
    _prefs = p;
  }

  // ── PLAYER NAME ──────────────────────────────────────────

  static String getPlayerName() {
    return _prefs?.getString(_keyPlayerName) ?? 'Guest Player';
  }

  static Future<void> setPlayerName(String name) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setString(_keyPlayerName, name);
    _prefs = p;
  }

  // ── SKIN ─────────────────────────────────────────────────

  static String getSkin() {
    return _prefs?.getString(_keySkin) ?? 'green_neon';
  }

  static Future<void> saveSkin(String skinId) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setString(_keySkin, skinId);
    _prefs = p;
  }

  // Owned skins stored as comma-separated IDs
  static List<String> getOwnedSkins() {
    final raw = _prefs?.getString('owned_skins') ?? 'green_neon';
    return raw.split(',');
  }

  static Future<void> addOwnedSkin(String skinId) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    final owned = getOwnedSkins();
    if (!owned.contains(skinId)) {
      owned.add(skinId);
      await p.setString('owned_skins', owned.join(','));
      _prefs = p;
    }
  }

  // ── SOUND & MUSIC ────────────────────────────────────────

  static bool getSoundEnabled() {
    return _prefs?.getBool(_keySound) ?? true;
  }

  static Future<void> saveSoundEnabled(bool value) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setBool(_keySound, value);
    _prefs = p;
  }

  static bool getMusicEnabled() {
    return _prefs?.getBool(_keyMusic) ?? true;
  }

  static Future<void> saveMusicEnabled(bool value) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setBool(_keyMusic, value);
    _prefs = p;
  }

  // ── DAILY REWARD ─────────────────────────────────────────

  static String getLastRewardDate() {
    return _prefs?.getString(_keyLastReward) ?? '';
  }

  static Future<void> saveLastRewardDate(String date) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setString(_keyLastReward, date);
    _prefs = p;
  }

  // ── DIFFICULTY ───────────────────────────────────────────

  static String getDifficulty() {
    return _prefs?.getString(_keyDifficulty) ?? 'normal'; // easy, normal, hard
  }

  static Future<void> saveDifficulty(String difficulty) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setString(_keyDifficulty, difficulty);
    _prefs = p;
  }
}
