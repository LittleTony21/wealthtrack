import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/milestone.dart';

class MilestoneQueueNotifier extends StateNotifier<List<MilestoneDefinition>> {
  MilestoneQueueNotifier() : super([]);

  void enqueue(List<MilestoneDefinition> milestones) {
    if (milestones.isEmpty) return;
    state = [...state, ...milestones];
  }

  void dequeue() {
    if (state.isNotEmpty) state = state.sublist(1);
  }
}

final milestoneQueueProvider =
    StateNotifierProvider<MilestoneQueueNotifier, List<MilestoneDefinition>>(
  (ref) => MilestoneQueueNotifier(),
);
