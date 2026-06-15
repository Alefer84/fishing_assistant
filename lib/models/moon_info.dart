import 'package:flutter/material.dart';

enum MoonPhase {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent,
}

extension MoonPhaseDisplay on MoonPhase {
  String get label => switch (this) {
        MoonPhase.newMoon => 'New Moon',
        MoonPhase.waxingCrescent => 'Waxing Crescent',
        MoonPhase.firstQuarter => 'First Quarter',
        MoonPhase.waxingGibbous => 'Waxing Gibbous',
        MoonPhase.fullMoon => 'Full Moon',
        MoonPhase.waningGibbous => 'Waning Gibbous',
        MoonPhase.lastQuarter => 'Last Quarter',
        MoonPhase.waningCrescent => 'Waning Crescent',
      };

  String get emoji => switch (this) {
        MoonPhase.newMoon => '🌑',
        MoonPhase.waxingCrescent => '🌒',
        MoonPhase.firstQuarter => '🌓',
        MoonPhase.waxingGibbous => '🌔',
        MoonPhase.fullMoon => '🌕',
        MoonPhase.waningGibbous => '🌖',
        MoonPhase.lastQuarter => '🌗',
        MoonPhase.waningCrescent => '🌘',
      };

  /// Solunar theory rates new and full moons as the strongest periods.
  bool get isFavorable =>
      this == MoonPhase.fullMoon || this == MoonPhase.newMoon;
}

@immutable
class SolunarPeriod {
  final TimeOfDay start;
  final TimeOfDay end;
  final bool isMajor;

  const SolunarPeriod({
    required this.start,
    required this.end,
    required this.isMajor,
  });
}

@immutable
class MoonInfo {
  final MoonPhase phase;

  /// Illuminated fraction of the disk, 0.0 - 1.0.
  final double illumination;

  /// Days since the last new moon.
  final double ageDays;
  final DateTime nextFullMoon;
  final DateTime nextNewMoon;
  final DateTime? moonrise;
  final DateTime? moonset;
  final List<SolunarPeriod> solunarPeriods;

  const MoonInfo({
    required this.phase,
    required this.illumination,
    required this.ageDays,
    required this.nextFullMoon,
    required this.nextNewMoon,
    required this.solunarPeriods,
    this.moonrise,
    this.moonset,
  });

  List<SolunarPeriod> get majorPeriods =>
      solunarPeriods.where((p) => p.isMajor).toList();

  List<SolunarPeriod> get minorPeriods =>
      solunarPeriods.where((p) => !p.isMajor).toList();
}
