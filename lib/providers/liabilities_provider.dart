import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/liability.dart';
import 'auth_provider.dart';

class LiabilitiesNotifier extends StateNotifier<AsyncValue<List<Liability>>> {
  final String? uid;
  StreamSubscription<QuerySnapshot>? _sub;

  LiabilitiesNotifier(this.uid) : super(const AsyncValue.loading()) {
    if (uid == null) {
      state = const AsyncValue.data([]);
    } else {
      _sub = FirebaseFirestore.instance
          .collection('users/$uid/liabilities')
          .orderBy('date_added', descending: true)
          .snapshots()
          .listen(
            (snap) => state = AsyncValue.data(
              snap.docs.map((d) => Liability.fromFirestore(d)).toList(),
            ),
            onError: (e, st) => state = AsyncValue.error(e, st as StackTrace),
          );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> add(Liability liability) async {
    if (uid == null) return;
    final col = FirebaseFirestore.instance.collection('users/$uid/liabilities');
    final doc = col.doc();
    await doc.set(liability.copyWith(id: doc.id, userId: uid!).toFirestore());
  }

  Future<void> update(Liability liability) async {
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users/$uid/liabilities')
        .doc(liability.id)
        .update(liability.toFirestore());
  }

  Future<void> delete(String id) async {
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users/$uid/liabilities')
        .doc(id)
        .delete();
  }
}

final liabilitiesProvider =
    StateNotifierProvider<LiabilitiesNotifier, AsyncValue<List<Liability>>>(
        (ref) {
  final user = ref.watch(currentUserProvider);
  return LiabilitiesNotifier(user?.uid);
});
