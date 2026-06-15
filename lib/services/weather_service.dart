import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/forecast.dart';
import '../models/weather.dart';

/// Fetches current conditions from Open-Meteo (free, no API key required).
class WeatherService {
  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  Future<Weather> fetchCurrent({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitude.toStringAsFixed(4),
      'longitude': longitude.toStringAsFixed(4),
      'current': 'temperature_2m,precipitation,weather_code,wind_speed_10m',
    });

    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw WeatherException('Open-Meteo returned ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final current = body['current'] as Map<String, dynamic>?;
    if (current == null) {
      throw const WeatherException('Missing current weather data');
    }

    return Weather(
      temperatureC: (current['temperature_2m'] as num).toDouble(),
      windSpeedKmh: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      precipitationMm: (current['precipitation'] as num?)?.toDouble(),
    );
  }

  /// Fetches an hourly (next ~2 days) and 7-day daily forecast.
  Future<Forecast> fetchForecast({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitude.toStringAsFixed(4),
      'longitude': longitude.toStringAsFixed(4),
      'hourly':
          'temperature_2m,precipitation_probability,precipitation,'
          'weather_code,cloud_cover,wind_speed_10m',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,'
          'precipitation_probability_max,wind_speed_10m_max,sunrise,sunset',
      'forecast_days': '7',
      'timezone': 'auto',
    });

    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw WeatherException('Open-Meteo returned ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final hourly = body['hourly'] as Map<String, dynamic>?;
    final daily = body['daily'] as Map<String, dynamic>?;
    if (hourly == null || daily == null) {
      throw const WeatherException('Missing forecast data');
    }

    return Forecast(hourly: _parseHourly(hourly), daily: _parseDaily(daily));
  }

  List<HourlyForecast> _parseHourly(Map<String, dynamic> hourly) {
    final times = (hourly['time'] as List).cast<String>();
    final temp = hourly['temperature_2m'] as List;
    final pop = hourly['precipitation_probability'] as List;
    final precip = hourly['precipitation'] as List;
    final code = hourly['weather_code'] as List;
    final cloud = hourly['cloud_cover'] as List;
    final wind = hourly['wind_speed_10m'] as List;

    return [
      for (var i = 0; i < times.length; i++)
        HourlyForecast(
          time: DateTime.parse(times[i]),
          temperatureC: _toDouble(temp[i]),
          precipitationProbability: _toInt(pop[i]),
          precipitationMm: _toDouble(precip[i]),
          weatherCode: _toInt(code[i]),
          cloudCoverPercent: _toDouble(cloud[i]),
          windSpeedKmh: _toDouble(wind[i]),
        ),
    ];
  }

  List<DailyForecast> _parseDaily(Map<String, dynamic> daily) {
    final dates = (daily['time'] as List).cast<String>();
    final code = daily['weather_code'] as List;
    final tmax = daily['temperature_2m_max'] as List;
    final tmin = daily['temperature_2m_min'] as List;
    final pop = daily['precipitation_probability_max'] as List;
    final wind = daily['wind_speed_10m_max'] as List;
    final sunrise = daily['sunrise'] as List;
    final sunset = daily['sunset'] as List;

    return [
      for (var i = 0; i < dates.length; i++)
        DailyForecast(
          date: DateTime.parse(dates[i]),
          weatherCode: _toInt(code[i]),
          temperatureMaxC: _toDouble(tmax[i]),
          temperatureMinC: _toDouble(tmin[i]),
          precipitationProbabilityMax: _toInt(pop[i]),
          windSpeedMaxKmh: _toDouble(wind[i]),
          sunrise: _tryParse(sunrise[i]),
          sunset: _tryParse(sunset[i]),
        ),
    ];
  }

  static double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0;

  static int _toInt(dynamic v) => (v as num?)?.toInt() ?? 0;

  static DateTime? _tryParse(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString());
}

class WeatherException implements Exception {
  final String message;
  const WeatherException(this.message);

  @override
  String toString() => 'WeatherException: $message';
}
