enum HatchStage { larva, nymph, emerger, adult, spinner }

enum HatchProbability { low, medium, high }

extension HatchProbabilityLabel on HatchProbability {
  String get label => switch (this) {
        HatchProbability.low => 'Low',
        HatchProbability.medium => 'Medium',
        HatchProbability.high => 'High',
      };
}

extension HatchStageLabel on HatchStage {
  String get label => switch (this) {
        HatchStage.larva => 'Larva',
        HatchStage.nymph => 'Nymph',
        HatchStage.emerger => 'Emerger',
        HatchStage.adult => 'Adult',
        HatchStage.spinner => 'Spinner',
      };
}

class Hatch {
  final String riverId;
  final String species;
  final HatchStage stage;

  /// Months (1-12) during which this hatch is typically active.
  final List<int> months;
  final HatchProbability probability;

  /// Recommended fly patterns for this hatch.
  final List<String> recommendedFlies;

  const Hatch({
    required this.riverId,
    required this.species,
    required this.stage,
    required this.months,
    required this.probability,
    required this.recommendedFlies,
  });

  bool isActiveIn(int month) => months.contains(month);
}
