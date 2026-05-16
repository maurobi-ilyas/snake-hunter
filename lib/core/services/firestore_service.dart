// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreService {
  /// True only after Firebase.initializeApp() succeeds
  static bool isAvailable = false;

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Call this after Firebase.initializeApp() — marks Firebase as usable.
  static void markAvailable() => isAvailable = true;

  /// Save score to online leaderboard. Silently fails if Firebase not configured.
  static Future<void> saveScore({
    required String playerName,
    required int score,
    required int level,
    required int coins,
  }) async {
    if (!isAvailable) return;
    try {
      await _db.collection('leaderboard').add({
        'playerName': playerName,
        'score': score,
        'level': level,
        'coins': coins,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('[FirestoreService] saveScore failed: $e');
    }
  }

  /// Stream of top 50 leaderboard entries. Returns null stream if not available.
  static Stream<QuerySnapshot>? leaderboardStream() {
    if (!isAvailable) return null;
    try {
      return _db
          .collection('leaderboard')
          .orderBy('score', descending: true)
          .limit(50)
          .snapshots();
    } catch (e) {
      print('[FirestoreService] leaderboardStream failed: $e');
      return null;
    }
  }
}
