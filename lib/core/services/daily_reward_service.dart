import 'local_storage_service.dart';

class DailyRewardService {
  static const int baseReward = 20;

  /// Returns true if the player hasn't claimed today's reward yet.
  static bool canClaimReward() {
    final last = LocalStorageService.getLastRewardDate();
    final today = _today();
    return last != today;
  }

  /// Claims the daily reward, saves the date, and returns the coin amount.
  static Future<int> claimReward() async {
    await LocalStorageService.saveLastRewardDate(_today());
    return baseReward;
  }

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
