import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/hydro_station.dart';
import '../models/water_reading.dart';

/// Fetches live hydrological readings from Poland's IMGW public API
/// (https://danepubliczne.imgw.pl, free, no API key). Each station reports
/// water level (cm), flow (m³/s) and water temperature (°C), updated ~hourly.
class ImgwHydroService {
  final http.Client _client;

  ImgwHydroService({http.Client? client}) : _client = client ?? http.Client();

  /// Live IMGW gauges selectable in the app, grouped by river.
  static const List<HydroStation> stations = [
    // Dunajec
    HydroStation(
      id: '149200160',
      name: 'Krościenko',
      riverId: 'dunajec',
      normalLevelCm: 160,
      normalFlowCms: 35,
    ),
    HydroStation(
      id: '149200140',
      name: 'Sromowce Wyżne',
      riverId: 'dunajec',
      normalLevelCm: 200,
      normalFlowCms: 28,
    ),
    HydroStation(
      id: '149200190',
      name: 'Gołkowice',
      riverId: 'dunajec',
      normalLevelCm: 150,
      normalFlowCms: 40,
    ),
    // San
    HydroStation(
      id: '149220060',
      name: 'Lesko',
      riverId: 'san',
      normalLevelCm: 150,
      normalFlowCms: 18,
    ),
  ];

  static List<HydroStation> stationsForRiver(String riverId) =>
      stations.where((s) => s.riverId == riverId).toList();

  static HydroStation stationById(String id) =>
      stations.firstWhere((s) => s.id == id, orElse: () => stations.first);

  Future<WaterReading> fetchStation(HydroStation station) async {
    final uri = Uri.https(
      'danepubliczne.imgw.pl',
      '/api/data/hydro/id/${station.id}',
    );

    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw ImgwException('IMGW returned ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final Map<String, dynamic> row;
    if (decoded is List) {
      if (decoded.isEmpty) {
        throw ImgwException('No data for station ${station.id}');
      }
      row = decoded.first as Map<String, dynamic>;
    } else {
      row = decoded as Map<String, dynamic>;
    }

    final levelCm = _toDouble(row['stan_wody']);
    if (levelCm == null) {
      throw ImgwException('Missing water level for ${station.name}');
    }
    final flowCms = _toDouble(row['przeplyw']);
    final tempC = _toDouble(row['temperatura_wody']);
    final measuredAt =
        _parseDate(row['stan_wody_data_pomiaru']) ?? DateTime.now();

    return WaterReading(
      riverId: station.riverId,
      levelMeters: levelCm,
      levelUnit: 'cm',
      flowCfs: flowCms ?? 0,
      flowUnit: 'm³/s',
      temperatureC: tempC,
      recordedAt: measuredAt,
      normalLevelMeters: station.normalLevelCm,
      normalFlowCfs: station.normalFlowCms,
      normalTemperatureC: 11,
      isLive: true,
      stationName: station.name,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '.'));
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString().replaceAll(' ', 'T'));
  }
}

class ImgwException implements Exception {
  final String message;
  const ImgwException(this.message);

  @override
  String toString() => 'ImgwException: $message';
}
