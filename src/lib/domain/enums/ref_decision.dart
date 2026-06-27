enum RefDecision {
  freeKick,         // Freistoß (direkt)
  indirectFreeKick, // Freistoß (indirekt)
  penalty,          // Strafstoß
  advantage,        // Vorteil
  playOn,           // Weiterspielen
  yellowCard,       // Verwarnung
  yellowRedCard,    // Feldverweis (GR)
  redCard,          // Feldverweis (R)
  cornerKick,       // Ecke
  goalKick,         // Abstoß
  throwIn,          // Einwurf
  goal,             // Tor/Anstoß
}

extension RefDecisionLabel on RefDecision {
  String get label => switch (this) {
    RefDecision.freeKick         => 'Freistoß',
    RefDecision.indirectFreeKick => 'Indir. FS',
    RefDecision.penalty          => 'Strafstoß',
    RefDecision.advantage        => 'Vorteil',
    RefDecision.playOn           => 'Weiter',
    RefDecision.yellowCard       => 'Gelb',
    RefDecision.yellowRedCard    => 'GR',
    RefDecision.redCard          => 'Rot',
    RefDecision.cornerKick       => 'Ecke',
    RefDecision.goalKick         => 'Abstoß',
    RefDecision.throwIn          => 'Einwurf',
    RefDecision.goal             => 'Tor',
  };
}
