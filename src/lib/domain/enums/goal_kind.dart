enum GoalKind {
  regular, // Standardtor
  ownGoal, // Eigentor
  penalty, // Strafstoßtor
}

extension GoalKindLabel on GoalKind {
  String get label => switch (this) {
    GoalKind.regular => 'Standardtor',
    GoalKind.ownGoal => 'Eigentor',
    GoalKind.penalty => 'Strafstoßtor',
  };

  /// Kurzkennzeichen für Listen — null beim Standardtor.
  String? get shortLabel => switch (this) {
    GoalKind.regular => null,
    GoalKind.ownGoal => 'ET',
    GoalKind.penalty => '11m',
  };
}
