import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/milestone.dart';
import '../models/user_profile.dart';
import 'auth_provider.dart';

class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final String? uid;
  StreamSubscription<DocumentSnapshot>? _sub;

  ProfileNotifier(this.uid) : super(const AsyncValue.loading()) {
    if (uid == null) {
      state = const AsyncValue.data(null);
    } else {
      _sub = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots()
          .listen(
        (doc) {
          if (doc.exists && doc.data() != null) {
            state = AsyncValue.data(UserProfile.fromJson({
              'id': uid,
              ...doc.data()!,
            }));
          } else {
            state = const AsyncValue.data(null);
          }
        },
        onError: (e, st) => state = AsyncValue.error(e, st),
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> update(UserProfile profile) async {
    if (uid == null) return;
    final data = profile.toJson()..remove('id');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  /// Returns true if coin was awarded, false if already checked in today.
  Future<bool> checkIn() async {
    final profile = state.valueOrNull;
    if (uid == null || profile == null) return false;

    final today = _dateStr(DateTime.now());
    if (profile.lastCheckIn == today) return false;

    final yesterday = _dateStr(DateTime.now().subtract(const Duration(days: 1)));
    final newStreak = profile.lastCheckIn == yesterday ? profile.streak + 1 : 1;
    final newDates = [...profile.checkInDates, today];

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'coins': profile.coins + 1,
      'streak': newStreak,
      'last_check_in': today,
      'check_in_dates': newDates,
    });
    return true;
  }

  Future<void> unlockFeatureWithCoins(String featureKey, int cost) async {
    final profile = state.valueOrNull;
    if (uid == null || profile == null) return;
    if (profile.coins < cost) return;
    if (profile.unlockedFeatures.contains(featureKey)) return;
    final newFeatures = [...profile.unlockedFeatures, featureKey];
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'coins': profile.coins - cost,
      'unlocked_features': newFeatures,
    });
  }

  /// Checks all milestone conditions against current data and awards any newly
  /// earned milestones. Returns the list of newly earned [MilestoneDefinition]s
  /// so the caller can show a notification.
  Future<List<MilestoneDefinition>> checkAndAwardMilestones({
    required double netWorth,
    required int assetCount,
    required int liabilityCount,
    required int streak,
    required bool isPremium,
    required bool hasUnlockedFeature,
    required int coins,
  }) async {
    final profile = state.valueOrNull;
    if (uid == null || profile == null) return [];

    final earned = profile.earnedMilestones;
    final newlyEarned = <MilestoneDefinition>[];

    bool _isNew(String id) => !earned.contains(id);

    for (final m in kMilestones) {
      if (!_isNew(m.id)) continue;
      bool conditionMet = false;
      switch (m.id) {
        case 'nw_positive':   conditionMet = netWorth > 0; break;
        case 'nw_1k':         conditionMet = netWorth >= 1000; break;
        case 'nw_10k':        conditionMet = netWorth >= 10000; break;
        case 'nw_100k':       conditionMet = netWorth >= 100000; break;
        case 'nw_1m':         conditionMet = netWorth >= 1000000; break;
        case 'streak_7':      conditionMet = streak >= 7; break;
        case 'streak_30':     conditionMet = streak >= 30; break;
        case 'streak_100':    conditionMet = streak >= 100; break;
        case 'assets_1':      conditionMet = assetCount >= 1; break;
        case 'assets_5':      conditionMet = assetCount >= 5; break;
        case 'assets_10':     conditionMet = assetCount >= 10; break;
        case 'first_liability': conditionMet = liabilityCount >= 1; break;
        case 'first_coin':    conditionMet = coins >= 1; break;
        case 'completionist': conditionMet = true; break; // awarded on first check after onboarding
        case 'premium_taste': conditionMet = hasUnlockedFeature; break;
        case 'go_premium':    conditionMet = isPremium; break;
      }
      if (conditionMet) newlyEarned.add(m);
    }

    if (newlyEarned.isEmpty) return [];

    final totalCoins = newlyEarned.fold(0, (s, m) => s + m.coinReward);
    final newIds = newlyEarned.map((m) => m.id).toList();

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'coins': profile.coins + totalCoins,
      'earned_milestones': [...earned, ...newIds],
    });

    return newlyEarned;
  }

  Future<void> upgradeToPremium() async {
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'is_premium': true});
  }

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  final user = ref.watch(currentUserProvider);
  return ProfileNotifier(user?.uid);
});
