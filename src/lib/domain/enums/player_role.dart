enum PlayerRole {
  fouler, // Fouler
  fouled, // Gefoulter
}

extension PlayerRoleLabel on PlayerRole {
  String get label => switch (this) {
    PlayerRole.fouler => 'Fouler',
    PlayerRole.fouled => 'Gefoulter',
  };
}
