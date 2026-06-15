import 'dart:math' as math;

import '../models/river.dart';
import '../models/water_reading.dart';

/// Phase 1 water conditions.
///
/// Live hydrological gauge integration (e.g. Poland's IMGW) is planned for a
/// later phase. For now this returns deterministic, realistic readings derived
/// from each river's seasonal baseline so the UI stays stable across a day.
class WaterService {
  const WaterService();

  /// Per-river seasonal baselines (normal level / flow / temperature).
  static const Map<String, ({double level, double flow, double temp})>
  _baselines = {
    'san': (level: 1.40, flow: 250, temp: 13),
    'dunajec': (level: 1.20, flow: 300, temp: 11),
    'wisla': (level: 2.10, flow: 480, temp: 15),
    'bobr': (level: 0.95, flow: 140, temp: 12),
  };

  WaterReading readingFor(River river, DateTime date) {
    final base = _baselines[river.id] ?? (level: 1.30, flow: 240.0, temp: 13.0);

    // Deterministic pseudo-random variation seeded by river + day so the
    // numbers are consistent within a day but vary day to day.
    final seed =
        river.id.hashCode ^ (date.year * 10000 + date.month * 100 + date.day);
    final rng = math.Random(seed);

    final flowFactor = 0.75 + rng.nextDouble() * 0.6; // 0.75x – 1.35x
    final levelFactor = 0.85 + rng.nextDouble() * 0.35; // 0.85x – 1.20x
    final tempDelta = (rng.nextDouble() * 6) - 3; // +/- 3 C

    return WaterReading(
      riverId: river.id,
      flowCfs: double.parse((base.flow * flowFactor).toStringAsFixed(0)),
      levelMeters: double.parse((base.level * levelFactor).toStringAsFixed(2)),
      temperatureC: double.parse((base.temp + tempDelta).toStringAsFixed(1)),
      recordedAt: date,
      normalFlowCfs: base.flow,
      normalLevelMeters: base.level,
      normalTemperatureC: base.temp,
    );
  }
}
