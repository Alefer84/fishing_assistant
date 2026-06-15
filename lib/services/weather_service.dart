import 'dart:convert';

import 'package:http/http.dart' as http;

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
}

class WeatherException implements Exception {
  final String message;
  const WeatherException(this.message);

  @override
  String toString() => 'WeatherException: $message';
}
