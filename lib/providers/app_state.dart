import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/fishing_log.dart';
import '../models/hatch.dart';
import '../models/hydro_station.dart';
import '../models/moon_info.dart';
import '../models/river.dart';
import '../models/water_reading.dart';
import '../models/weather.dart';
import '../services/hatch_service.dart';
import '../services/imgw_hydro_service.dart';
import '../services/log_service.dart';
import '../services/moon_service.dart';
import '../services/river_service.dart';
import '../services/score_service.dart';
import '../services/water_service.dart';
import '../services/weather_service.dart';

/// Snapshot of all conditions for the selected river "today".
class Conditions {
  final WaterReading water;
  final MoonInfo moon;
  final List<Hatch> activeHatches;
  final List<String> recommendedFlies;
  final FishingScore score;
  final Weather? weather;
  final String? weatherError;

  /// Set when the live IMGW gauge could not be reached and a stub reading was
  /// used instead.
  final String? waterError;

  const Conditions({
    required this.water,
    required this.moon,
    required this.activeHatches,
    required this.recommendedFlies,
    required this.score,
    this.weather,
    this.weatherError,
    this.waterError,
  });
}

class AppState extends ChangeNotifier {
  final RiverService _riverService;
  final WaterService _waterService;
  final MoonService _moonService;
  final HatchService _hatchService;
  final ScoreService _scoreService;
  final WeatherService _weatherService;
  final ImgwHydroService _imgwService;
  final LogService _logService;

  /// How often live IMGW data is automatically pulled while the app is open.
  static const Duration liveRefreshInterval = Duration(hours: 2);

  AppState({
    RiverService? riverService,
    WaterService? waterService,
    MoonService? moonService,
    HatchService? hatchService,
    ScoreService? scoreService,
    WeatherService? weatherService,
    ImgwHydroService? imgwService,
    LogService? logService,
  }) : _riverService = riverService ?? RiverService(),
       _waterService = waterService ?? const WaterService(),
       _moonService = moonService ?? const MoonService(),
       _hatchService = hatchService ?? const HatchService(),
       _scoreService = scoreService ?? const ScoreService(),
       _weatherService = weatherService ?? WeatherService(),
       _imgwService = imgwService ?? ImgwHydroService(),
       _logService = logService ?? LogService();

  River _selectedRiver = RiverService.rivers.first;
  River get selectedRiver => _selectedRiver;

  Set<String> _favorites = {};
  Set<String> get favorites => _favorites;

  Conditions? _conditions;
  Conditions? get conditions => _conditions;

  bool _loading = false;
  bool get loading => _loading;

  List<FishingLog> _logs = [];
  List<FishingLog> get logs => List.unmodifiable(_logs);

  List<River> get rivers => RiverService.rivers;
  RiverService get riverService => _riverService;
  MoonService get moonService => _moonService;
  HatchService get hatchService => _hatchService;

  /// Selected live gauge per river (id of the [HydroStation]).
  final Map<String, String> _selectedStationByRiver = {};
  Timer? _refreshTimer;

  /// Live gauge stations available for the selected river (empty if none).
  List<HydroStation> get availableStations =>
      ImgwHydroService.stationsForRiver(_selectedRiver.id);

  HydroStation? get selectedStation {
    final stations = availableStations;
    if (stations.isEmpty) return null;
    final id = _selectedStationByRiver[_selectedRiver.id];
    return ImgwHydroService.stationById(id ?? stations.first.id);
  }

  Future<void> init({bool autoRefresh = true}) async {
    _favorites = await _riverService.loadFavorites();
    _logs = await _logService.loadLogs();
    await refreshConditions();
    if (autoRefresh) {
      _refreshTimer?.cancel();
      _refreshTimer = Timer.periodic(
        liveRefreshInterval,
        (_) => refreshConditions(),
      );
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> selectWaterStation(HydroStation station) async {
    _selectedStationByRiver[_selectedRiver.id] = station.id;
    notifyListeners();
    await refreshConditions();
  }

  Future<void> selectRiver(River river) async {
    _selectedRiver = river;
    notifyListeners();
    await refreshConditions();
  }

  Future<void> toggleFavorite(River river) async {
    await _riverService.toggleFavorite(river.id);
    _favorites = await _riverService.loadFavorites();
    notifyListeners();
  }

  bool isFavorite(River river) => _favorites.contains(river.id);

  Future<void> refreshConditions() async {
    _loading = true;
    notifyListeners();

    final now = DateTime.now();
    final river = _selectedRiver;

    String? waterError;
    WaterReading water;
    final station = selectedStation;
    if (station != null) {
      try {
        water = await _imgwService.fetchStation(station);
      } catch (e) {
        waterError = 'Live gauge unavailable; showing estimate';
        water = _waterService.readingFor(river, now);
      }
    } else {
      water = _waterService.readingFor(river, now);
    }

    final moon = _moonService.compute(
      when: now,
      latitude: river.latitude,
      longitude: river.longitude,
    );
    final activeHatches = _hatchService.activeHatches(river.id, now.month);
    final recommendedFlies = _hatchService.recommendedFlies(
      river.id,
      now.month,
    );
    final score = _scoreService.compute(
      water: water,
      moon: moon,
      activeHatches: activeHatches,
    );

    Weather? weather;
    String? weatherError;
    try {
      weather = await _weatherService.fetchCurrent(
        latitude: river.latitude,
        longitude: river.longitude,
      );
    } catch (e) {
      weatherError = 'Weather unavailable';
    }

    _conditions = Conditions(
      water: water,
      moon: moon,
      activeHatches: activeHatches,
      recommendedFlies: recommendedFlies,
      score: score,
      weather: weather,
      weatherError: weatherError,
      waterError: waterError,
    );
    _loading = false;
    notifyListeners();
  }

  Future<void> addLog(FishingLog log) async {
    await _logService.addLog(log);
    _logs = await _logService.loadLogs();
    notifyListeners();
  }

  Future<void> deleteLog(String id) async {
    await _logService.deleteLog(id);
    _logs = await _logService.loadLogs();
    notifyListeners();
  }
}
