import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../../domain/models/goal.dart';

final goalsProvider = StateNotifierProvider<GoalsNotifier, AsyncValue<List<Goal>>>((ref) {
  return GoalsNotifier(ref);
});

class GoalsNotifier extends StateNotifier<AsyncValue<List<Goal>>> {
  final Ref _ref;

  GoalsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadGoals();
  }

  Future<void> loadGoals() async {
    state = const AsyncValue.loading();
    try {
      final api = _ref.read(apiServiceProvider);
      final data = await api.getGoals();
      final goals = data.map((e) => Goal.fromJson(e)).toList();
      state = AsyncValue.data(goals);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addGoal({
    required String title,
    required double targetAmount,
    required String category,
    required String icon,
    DateTime? targetDate,
  }) async {
    try {
      final api = _ref.read(apiServiceProvider);
      await api.createGoal({
        'title': title,
        'target_amount': targetAmount,
        'current_amount': 0.0,
        'category': category,
        'icon': icon,
        'target_date': targetDate?.toIso8601String(),
      });
      await loadGoals();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProgress(int goalId, double currentAmount) async {
    try {
      final api = _ref.read(apiServiceProvider);
      final currentGoals = state.value ?? [];
      final goal = currentGoals.firstWhere((g) => g.id == goalId);
      
      await api.updateGoal(goalId, {
        ...goal.toJson(),
        'current_amount': currentAmount,
      });
      await loadGoals();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGoal(int goalId) async {
    try {
      final api = _ref.read(apiServiceProvider);
      await api.deleteGoal(goalId);
      await loadGoals();
    } catch (e) {
      rethrow;
    }
  }
}
