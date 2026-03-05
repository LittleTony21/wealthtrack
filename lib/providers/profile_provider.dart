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
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  final user = ref.watch(currentUserProvider);
  return ProfileNotifier(user?.uid);
});
