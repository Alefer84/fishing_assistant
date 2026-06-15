import '../models/hatch.dart';
import '../models/moon_info.dart';
import '../models/water_reading.dart';

class ScoreFactor {
  final String label;
  final int points;
  final bool achieved;

  const ScoreFactor(this.label, this.points, this.achieved);
}

class FishingScore {
  final int total;
  final List<ScoreFactor> factors;

  const FishingScore(this.total, this.factors);

  String get rating {
    if (total <= 3) return 'Poor';
    if (total <= 6) return 'Fair';
    if (total <= 8) return 'Good';
    return 'Excellent';
  }
}

/// Implements the rule-based fishing score from the guideline:
/// water level normal (+3), ideal water temp (+2), favorable moon (+2),
/// active hatch (+3), for a 0-10 scale.
class ScoreService {
  const ScoreService();

  static const double _idealTempMin = 8;
  static const double _idealTempMax = 16;

  FishingScore compute({
    required WaterReading water,
    required MoonInfo moon,
    required List<Hatch> activeHatches,
  }) {
    final levelNormal = water.isFlowNearNormal;
    final temp = water.temperatureC;
    final tempIdeal =
        temp != null && temp >= _idealTempMin && temp <= _idealTempMax;
    final moonFavorable = moon.phase.isFavorable;
    final hatchActive = activeHatches.isNotEmpty;

    final factors = [
      ScoreFactor('Water level / flow near normal', 3, levelNormal),
      ScoreFactor('Water temperature ideal (8-16°C)', 2, tempIdeal),
      ScoreFactor('Moon phase favorable', 2, moonFavorable),
      ScoreFactor('Active hatch today', 3, hatchActive),
    ];

    final total = factors
        .where((f) => f.achieved)
        .fold(0, (sum, f) => sum + f.points);

    return FishingScore(total, factors);
  }
}
