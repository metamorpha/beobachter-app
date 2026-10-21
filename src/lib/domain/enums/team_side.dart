enum TeamSide {
  home, // Heimmannschaft
  away, // Gastmannschaft
}

extension TeamSideLabel on TeamSide {
  String get label => switch (this) {
    TeamSide.home => 'Heim',
    TeamSide.away => 'Gast',
  };

  TeamSide get opponent => this == TeamSide.home ? TeamSide.away : TeamSide.home;
}
