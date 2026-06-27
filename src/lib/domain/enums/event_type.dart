enum EventType {
  footFoul,     // Fußvergehen
  bodyFoul,     // Oberkörpervergehen
  handball,     // Handspiel
  unsporting,   // Unsportlichkeit
  violent,      // Tätlichkeit
  offside,      // Abseits
  advantage,    // Vorteilsbestimmung
  goalDecision, // Torentscheidung
  custom,       // Sonstiges
}

extension EventTypeLabel on EventType {
  String get label => switch (this) {
    EventType.footFoul     => 'Fußvergehen',
    EventType.bodyFoul     => 'Oberkörperverg.',
    EventType.handball     => 'Handspiel',
    EventType.unsporting   => 'Unsportl.',
    EventType.violent      => 'Tätlichkeit',
    EventType.offside      => 'Abseits',
    EventType.advantage    => 'Vorteil',
    EventType.goalDecision => 'Torentsch.',
    EventType.custom       => 'Sonstiges',
  };
}
