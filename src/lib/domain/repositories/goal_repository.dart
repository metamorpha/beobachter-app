import '../entities/goal.dart';

abstract class GoalRepository {
  Future<Goal> createGoal(Goal goal);
  Future<List<Goal>> getGoals(String gameId);
  Future<void> updateGoal(Goal goal);
  Future<void> deleteGoal(String id);
}
