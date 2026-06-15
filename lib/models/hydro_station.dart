/// A live IMGW hydrological gauge station.
///
/// `normalLevelCm` / `normalFlowCms` are approximate typical baselines used for
/// the "vs normal" comparison and the fishing score; live values come from IMGW.
class HydroStation {
  final String id;
  final String name;
  final String riverId;
  final double latitude;
  final double longitude;
  final double normalLevelCm;
  final double normalFlowCms;

  const HydroStation({
    required this.id,
    required this.name,
    required this.riverId,
    required this.latitude,
    required this.longitude,
    required this.normalLevelCm,
    required this.normalFlowCms,
  });
}
