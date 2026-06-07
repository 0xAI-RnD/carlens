import 'package:shared_preferences/shared_preferences.dart';

/// Tracks a per-batch scan limit (soft usage friction, no hard paywall).
///
/// The counter is fully independent from the garage database: it reads and
/// writes ONLY its own SharedPreferences key, so deleting garage scans never
/// changes the remaining count. Refills are unlimited — [refill] always resets
/// the batch back to [batchSize].
class ScanLimitService {
  static final ScanLimitService _instance = ScanLimitService._internal();
  factory ScanLimitService() => _instance;
  ScanLimitService._internal();

  /// Number of scans granted per batch.
  static const int batchSize = 5;

  /// Dedicated SharedPreferences key, independent from the garage DB.
  static const String _usedKey = 'scan_limit_used';

  /// How many scans of the current batch have been consumed (0..batchSize).
  Future<int> getUsed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_usedKey) ?? 0;
  }

  /// Scans left in the current batch, clamped to [0, batchSize].
  Future<int> remaining() async {
    final used = await getUsed();
    return (batchSize - used).clamp(0, batchSize);
  }

  /// Whether the user can still scan in this batch.
  Future<bool> canScan() async => (await remaining()) > 0;

  /// Consumes one scan. Never exceeds [batchSize] (clamped).
  ///
  /// Call this ONLY when an analysis actually starts (image selected or valid
  /// URL extracted), never on picker cancel or invalid clipboard.
  Future<void> consume() async {
    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getInt(_usedKey) ?? 0;
    if (used < batchSize) {
      await prefs.setInt(_usedKey, used + 1);
    }
  }

  /// Refills the batch by resetting the used counter to 0. Unlimited refills.
  Future<void> refill() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_usedKey, 0);
  }
}
