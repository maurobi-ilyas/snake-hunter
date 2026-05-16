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
  static const _keyTheme = 'selected_theme';
  static const _keyTrail = 'selected_trail';

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

  // ── THEME ────────────────────────────────────────────────
  
  static String getTheme() {
    return _prefs?.getString(_keyTheme) ?? 'cyber_river';
  }

  static Future<void> saveTheme(String themeId) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setString(_keyTheme, themeId);
    _prefs = p;
  }

  static List<String> getOwnedThemes() {
    final raw = _prefs?.getString('owned_themes') ?? 'cyber_river';
    return raw.split(',');
  }

  static Future<void> addOwnedTheme(String themeId) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    final owned = getOwnedThemes();
    if (!owned.contains(themeId)) {
      owned.add(themeId);
      await p.setString('owned_themes', owned.join(','));
      _prefs = p;
    }
  }

  // ── TRAIL ────────────────────────────────────────────────
  
  static String getTrail() {
    return _prefs?.getString(_keyTrail) ?? 'none';
  }

  static Future<void> saveTrail(String trailId) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setString(_keyTrail, trailId);
    _prefs = p;
  }

  static List<String> getOwnedTrails() {
    final raw = _prefs?.getString('owned_trails') ?? 'none';
    return raw.split(',');
  }

  static Future<void> addOwnedTrail(String trailId) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    final owned = getOwnedTrails();
    if (!owned.contains(trailId)) {
      owned.add(trailId);
      await p.setString('owned_trails', owned.join(','));
      _prefs = p;
    }
  }

  // ── BOOSTS ───────────────────────────────────────────────
  
  static int getBoostCount(String boostId) {
    return _prefs?.getInt('boost_$boostId') ?? 0;
  }

  static Future<void> addBoost(String boostId, int amount) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    final current = getBoostCount(boostId);
    await p.setInt('boost_$boostId', current + amount);
    _prefs = p;
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
