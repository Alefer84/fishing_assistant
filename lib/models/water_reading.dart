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

  /// Units the level/flow values are expressed in. Defaults match the Phase 1
  /// stub; live IMGW readings use 'cm' and 'm³/s'.
  final String levelUnit;
  final String flowUnit;

  /// Set when the reading comes from a live gauge (IMGW) rather than the stub.
  final bool isLive;
  final String? stationName;

  const WaterReading({
    required this.riverId,
    required this.levelMeters,
    required this.flowCfs,
    required this.recordedAt,
    required this.normalLevelMeters,
    required this.normalFlowCfs,
    this.temperatureC,
    this.normalTemperatureC,
    this.levelUnit = 'm',
    this.flowUnit = 'CFS',
    this.isLive = false,
    this.stationName,
  });

  /// Flow deviation from normal as a signed percentage (e.g. +18%).
  double get flowDeviationPercent =>
      ((flowCfs - normalFlowCfs) / normalFlowCfs) * 100;

  double get levelDeviationPercent =>
      ((levelMeters - normalLevelMeters) / normalLevelMeters) * 100;

  /// True when flow sits within +/-20% of the normal baseline.
  bool get isFlowNearNormal => flowDeviationPercent.abs() <= 20;

  String get levelDisplay => '${_fmt(levelMeters, levelUnit)} $levelUnit';
  String get normalLevelDisplay =>
      '${_fmt(normalLevelMeters, levelUnit)} $levelUnit';
  String get flowDisplay => '${_fmt(flowCfs, flowUnit)} $flowUnit';
  String get normalFlowDisplay => '${_fmt(normalFlowCfs, flowUnit)} $flowUnit';

  static String _fmt(double value, String unit) {
    switch (unit) {
      case 'cm':
      case 'CFS':
        return value.toStringAsFixed(0);
      case 'm³/s':
        return value.toStringAsFixed(1);
      default:
        return value.toStringAsFixed(2);
    }
  }
}
