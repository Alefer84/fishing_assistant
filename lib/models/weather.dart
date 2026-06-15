class Weather {
  final double temperatureC;
  final double windSpeedKmh;
  final int weatherCode;
  final double? precipitationMm;

  const Weather({
    required this.temperatureC,
    required this.windSpeedKmh,
    required this.weatherCode,
    this.precipitationMm,
  });

  /// Human-readable description of the WMO weather code returned by Open-Meteo.
  String get description {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode <= 2) return 'Partly cloudy';
    if (weatherCode == 3) return 'Overcast';
    if (weatherCode <= 48) return 'Fog';
    if (weatherCode <= 57) return 'Drizzle';
    if (weatherCode <= 67) return 'Rain';
    if (weatherCode <= 77) return 'Snow';
    if (weatherCode <= 82) return 'Rain showers';
    if (weatherCode <= 86) return 'Snow showers';
    return 'Thunderstorm';
  }
}
