import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  final user = ref.watch(currentUserProvider);
  return ProfileNotifier(user?.uid);
});
