import 'package:flutter/material.dart';

/// Maps a WMO weather code (from Open-Meteo) to a Material icon.
IconData weatherIcon(int code, {bool isNight = false}) {
  if (code == 0) return isNight ? Icons.nightlight_round : Icons.wb_sunny;
  if (code <= 2) {
    return isNight ? Icons.nights_stay : Icons.wb_cloudy;
  }
  if (code == 3) return Icons.cloud;
  if (code <= 48) return Icons.foggy;
  if (code <= 57) return Icons.grain;
  if (code <= 67) return Icons.water_drop;
  if (code <= 77) return Icons.ac_unit;
  if (code <= 82) return Icons.umbrella;
  if (code <= 86) return Icons.cloudy_snowing;
  return Icons.thunderstorm;
}

/// A tint colour to make the icon read at a glance.
Color weatherIconColor(int code) {
  if (code == 0) return const Color(0xFFF5A623); // sun
  if (code <= 2) return const Color(0xFFF5A623);
  if (code == 3) return const Color(0xFF8A94A6); // overcast grey
  if (code <= 48) return const Color(0xFF9AA0A6); // fog
  if (code <= 67) return const Color(0xFF3D8BFD); // rain blue
  if (code <= 86) return const Color(0xFF6CB4EE); // snow
  return const Color(0xFF7E57C2); // storm purple
}

String weatherDescription(int code) {
  if (code == 0) return 'Clear sky';
  if (code <= 2) return 'Partly cloudy';
  if (code == 3) return 'Overcast';
  if (code <= 48) return 'Fog';
  if (code <= 57) return 'Drizzle';
  if (code <= 67) return 'Rain';
  if (code <= 77) return 'Snow';
  if (code <= 82) return 'Rain showers';
  if (code <= 86) return 'Snow showers';
  return 'Thunderstorm';
}
