import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class PinNotifier extends StateNotifier<bool> {
  PinNotifier() : super(false);
  void unlock() => state = true;
}

// Auto-resets to false whenever the current user changes (sign in/out)
final pinUnlockedProvider = StateNotifierProvider<PinNotifier, bool>((ref) {
  ref.watch(currentUserProvider);
  return PinNotifier();
});
