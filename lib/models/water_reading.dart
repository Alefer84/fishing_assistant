class WaterReading {
  final String riverId;
  final double levelMeters;
  final double flowCfs;
  final double? temperatureC;
  final DateTime recordedAt;

  /// Seasonal "normal" baselines used for the historical comparison.
  final double normalLevelMeters;
  final double normalFlowCfs;
  final double? normalTemperatureC;

  const WaterReading({
    required this.riverId,
    required this.levelMeters,
    required this.flowCfs,
    required this.recordedAt,
    required this.normalLevelMeters,
    required this.normalFlowCfs,
    this.temperatureC,
    this.normalTemperatureC,
  });

  /// Flow deviation from normal as a signed percentage (e.g. +18%).
  double get flowDeviationPercent =>
      ((flowCfs - normalFlowCfs) / normalFlowCfs) * 100;

  double get levelDeviationPercent =>
      ((levelMeters - normalLevelMeters) / normalLevelMeters) * 100;

  /// True when flow sits within +/-20% of the normal baseline.
  bool get isFlowNearNormal => flowDeviationPercent.abs() <= 20;
}
