/// A single hourly forecast point.
class HourlyForecast {
  final DateTime time;
  final double temperatureC;
  final int weatherCode;
  final double precipitationMm;
  final int precipitationProbability;
  final double cloudCoverPercent;
  final double windSpeedKmh;

  const HourlyForecast({
    required this.time,
    required this.temperatureC,
    required this.weatherCode,
    required this.precipitationMm,
    required this.precipitationProbability,
    required this.cloudCoverPercent,
    required this.windSpeedKmh,
  });
}

/// A single day's forecast summary.
class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double temperatureMaxC;
  final double temperatureMinC;
  final int precipitationProbabilityMax;
  final double windSpeedMaxKmh;
  final DateTime? sunrise;
  final DateTime? sunset;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.temperatureMaxC,
    required this.temperatureMinC,
    required this.precipitationProbabilityMax,
    required this.windSpeedMaxKmh,
    this.sunrise,
    this.sunset,
  });
}

/// Combined hourly + daily forecast for a location.
class Forecast {
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  const Forecast({required this.hourly, required this.daily});

  /// The next [count] hourly points from [from] (defaults to now), inclusive of
  /// the current hour.
  List<HourlyForecast> upcomingHours({int count = 24, DateTime? from}) {
    final start = from ?? DateTime.now();
    final startHour = DateTime(start.year, start.month, start.day, start.hour);
    final upcoming = hourly.where((h) => !h.time.isBefore(startHour)).toList();
    return upcoming.take(count).toList();
  }

  DailyForecast? get today => daily.isEmpty ? null : daily.first;
}
