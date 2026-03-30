import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/asset.dart';
import 'auth_provider.dart';

class AssetsNotifier extends StateNotifier<AsyncValue<List<Asset>>> {
  final String? uid;
  StreamSubscription<QuerySnapshot>? _sub;

  AssetsNotifier(this.uid) : super(const AsyncValue.loading()) {
    if (uid == null) {
      state = const AsyncValue.data([]);
    } else {
      _sub = FirebaseFirestore.instance
          .collection('users/$uid/assets')
          .orderBy('purchase_date', descending: true)
          .snapshots()
          .listen(
            (snap) => state = AsyncValue.data(
              snap.docs.map((d) => Asset.fromFirestore(d)).toList(),
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

  Future<void> add(Asset asset) async {
    if (uid == null) return;
    final col = FirebaseFirestore.instance.collection('users/$uid/assets');
    final doc = col.doc();
    await doc.set(asset.copyWith(id: doc.id, userId: uid!).toFirestore());
  }

  Future<void> update(Asset asset) async {
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users/$uid/assets')
        .doc(asset.id)
        .update(asset.toFirestore());
  }

  Future<void> delete(String id) async {
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users/$uid/assets')
        .doc(id)
        .delete();
  }
}

final assetsProvider =
    StateNotifierProvider<AssetsNotifier, AsyncValue<List<Asset>>>((ref) {
  final user = ref.watch(currentUserProvider);
  return AssetsNotifier(user?.uid);
});
