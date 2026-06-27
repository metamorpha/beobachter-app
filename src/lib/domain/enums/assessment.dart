enum Assessment {
  correctExpected, // Korrekt · Erwartbar
  correctComplex,  // Korrekt · Komplex
  wrongExpected,   // Falsch · Erwartbar
  wrongComplex,    // Falsch · Komplex
}

extension AssessmentProperties on Assessment {
  bool get isCorrect =>
      this == Assessment.correctExpected || this == Assessment.correctComplex;

  bool get isComplex =>
      this == Assessment.correctComplex || this == Assessment.wrongComplex;

  String get label => switch (this) {
    Assessment.correctExpected => 'Korrekt · Erwartbar',
    Assessment.correctComplex  => 'Korrekt · Komplex',
    Assessment.wrongExpected   => 'Falsch · Erwartbar',
    Assessment.wrongComplex    => 'Falsch · Komplex',
  };
}
