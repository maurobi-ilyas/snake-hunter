// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Save score to online leaderboard. Silently fails if Firebase not configured.
  static Future<void> saveScore({
    required String playerName,
    required int score,
    required int level,
    required int coins,
  }) async {
    try {
      await _db.collection('leaderboard').add({
        'playerName': playerName,
        'score': score,
        'level': level,
        'coins': coins,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('[FirestoreService] saveScore failed (Firebase not configured?): $e');
    }
  }

  /// Stream of top 50 leaderboard entries ordered by score descending.
  static Stream<QuerySnapshot> leaderboardStream() {
    return _db
        .collection('leaderboard')
        .orderBy('score', descending: true)
        .limit(50)
        .snapshots();
  }
}
