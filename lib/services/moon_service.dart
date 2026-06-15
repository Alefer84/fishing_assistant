import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/moon_info.dart';

/// On-device lunar calculations: phase, illumination, rise/set, and solunar
/// periods. Positions use Paul Schlyter's low-precision lunar theory which is
/// accurate to a few arc-minutes — more than enough for fishing guidance.
class MoonService {
  static const double _synodicMonth = 29.530588853;

  /// Reference new moon: 2000-01-06 18:14 UTC (Julian date 2451550.26).
  static const double _knownNewMoonJd = 2451550.26;

  const MoonService();

  MoonInfo compute({
    required DateTime when,
    required double latitude,
    required double longitude,
  }) {
    final utc = when.toUtc();
    final age = _moonAgeDays(utc);
    final phase = _phaseFromAge(age);
    final illumination = (1 - math.cos(2 * math.pi * age / _synodicMonth)) / 2;

    final nextFull = _nextPhaseDate(utc, _synodicMonth / 2);
    final nextNew = _nextPhaseDate(utc, _synodicMonth);

    final events = _dayEvents(when, latitude, longitude);

    return MoonInfo(
      phase: phase,
      illumination: illumination,
      ageDays: age,
      nextFullMoon: nextFull,
      nextNewMoon: nextNew,
      moonrise: events.rise,
      moonset: events.set,
      solunarPeriods: _solunarPeriods(events),
    );
  }

  /// Moon phase for an arbitrary day, used by the monthly calendar.
  MoonPhase phaseForDate(DateTime date) =>
      _phaseFromAge(_moonAgeDays(date.toUtc()));

  double _moonAgeDays(DateTime utc) {
    final days = _julianDay(utc) - _knownNewMoonJd;
    final age = days % _synodicMonth;
    return age < 0 ? age + _synodicMonth : age;
  }

  MoonPhase _phaseFromAge(double age) {
    final f = age / _synodicMonth;
    if (f < 0.0185 || f >= 0.9815) return MoonPhase.newMoon;
    if (f < 0.2315) return MoonPhase.waxingCrescent;
    if (f < 0.2685) return MoonPhase.firstQuarter;
    if (f < 0.4815) return MoonPhase.waxingGibbous;
    if (f < 0.5185) return MoonPhase.fullMoon;
    if (f < 0.7315) return MoonPhase.waningGibbous;
    if (f < 0.7685) return MoonPhase.lastQuarter;
    return MoonPhase.waningCrescent;
  }

  /// Days from `from` until the moon next reaches `targetAge` in its cycle.
  DateTime _nextPhaseDate(DateTime from, double targetAge) {
    final age = _moonAgeDays(from);
    var delta = targetAge - age;
    if (delta <= 0) delta += _synodicMonth;
    return from.add(Duration(seconds: (delta * 86400).round())).toLocal();
  }

  static double _julianDay(DateTime utc) {
    var y = utc.year;
    var m = utc.month;
    final d = utc.day + (utc.hour + utc.minute / 60 + utc.second / 3600) / 24;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524.5;
  }

  static double _rad(double deg) => deg * math.pi / 180;
  static double _deg(double rad) => rad * 180 / math.pi;
  static double _rev(double deg) {
    final r = deg % 360;
    return r < 0 ? r + 360 : r;
  }

  /// Geocentric right ascension and declination of the Moon (degrees).
  static ({double ra, double dec}) _moonEquatorial(DateTime utc) {
    final d = _julianDay(utc) - 2451543.5;

    final n = _rev(125.1228 - 0.0529538083 * d);
    const i = 5.1454;
    final w = _rev(318.0634 + 0.1643573223 * d);
    const a = 60.2666;
    const e = 0.054900;
    final mm = _rev(115.3654 + 13.0649929509 * d);

    var ecc = mm + _deg(e) * math.sin(_rad(mm)) * (1 + e * math.cos(_rad(mm)));
    for (var k = 0; k < 5; k++) {
      ecc =
          ecc -
          (ecc - _deg(e) * math.sin(_rad(ecc)) - mm) /
              (1 - e * math.cos(_rad(ecc)));
    }

    final xv = a * (math.cos(_rad(ecc)) - e);
    final yv = a * (math.sqrt(1 - e * e) * math.sin(_rad(ecc)));
    final v = _rev(_deg(math.atan2(yv, xv)));
    final r = math.sqrt(xv * xv + yv * yv);

    final xh =
        r *
        (math.cos(_rad(n)) * math.cos(_rad(v + w)) -
            math.sin(_rad(n)) * math.sin(_rad(v + w)) * math.cos(_rad(i)));
    final yh =
        r *
        (math.sin(_rad(n)) * math.cos(_rad(v + w)) +
            math.cos(_rad(n)) * math.sin(_rad(v + w)) * math.cos(_rad(i)));
    final zh = r * (math.sin(_rad(v + w)) * math.sin(_rad(i)));

    var lon = _rev(_deg(math.atan2(yh, xh)));
    var lat = _deg(math.atan2(zh, math.sqrt(xh * xh + yh * yh)));

    // Main periodic perturbations.
    final ms = _rev(356.0470 + 0.9856002585 * d);
    final ws = 282.9404 + 4.70935e-5 * d;
    final ls = _rev(ws + ms);
    final lm = _rev(n + w + mm);
    final dEl = _rev(lm - ls);
    final f = _rev(lm - n);

    lon +=
        -1.274 * math.sin(_rad(mm - 2 * dEl)) +
        0.658 * math.sin(_rad(2 * dEl)) -
        0.186 * math.sin(_rad(ms)) -
        0.059 * math.sin(_rad(2 * mm - 2 * dEl)) -
        0.057 * math.sin(_rad(mm - 2 * dEl + ms)) +
        0.053 * math.sin(_rad(mm + 2 * dEl)) +
        0.046 * math.sin(_rad(2 * dEl - ms)) +
        0.041 * math.sin(_rad(mm - ms)) -
        0.035 * math.sin(_rad(dEl)) -
        0.031 * math.sin(_rad(mm + ms)) -
        0.015 * math.sin(_rad(2 * f - 2 * dEl)) +
        0.011 * math.sin(_rad(mm - 4 * dEl));

    lat +=
        -0.173 * math.sin(_rad(f - 2 * dEl)) -
        0.055 * math.sin(_rad(mm - f - 2 * dEl)) -
        0.046 * math.sin(_rad(mm + f - 2 * dEl)) +
        0.033 * math.sin(_rad(f + 2 * dEl)) +
        0.017 * math.sin(_rad(2 * mm + f));

    final ecl = 23.4393 - 3.563e-7 * d;
    final x = math.cos(_rad(lon)) * math.cos(_rad(lat));
    final y = math.sin(_rad(lon)) * math.cos(_rad(lat));
    final z = math.sin(_rad(lat));

    final xe = x;
    final ye = y * math.cos(_rad(ecl)) - z * math.sin(_rad(ecl));
    final ze = y * math.sin(_rad(ecl)) + z * math.cos(_rad(ecl));

    final ra = _rev(_deg(math.atan2(ye, xe)));
    final dec = _deg(math.atan2(ze, math.sqrt(xe * xe + ye * ye)));
    return (ra: ra, dec: dec);
  }

  /// Moon altitude (degrees) at a given instant and observer location.
  static double _altitude(DateTime utc, double lat, double lon) {
    final pos = _moonEquatorial(utc);
    final d = _julianDay(utc) - 2451543.5;
    final ws = 282.9404 + 4.70935e-5 * d;
    final ms = _rev(356.0470 + 0.9856002585 * d);
    final ls = _rev(ws + ms);
    final ut = utc.hour + utc.minute / 60 + utc.second / 3600;
    final gmst0 = _rev(ls + 180) / 15;
    final lst = gmst0 + ut + lon / 15;
    final ha = _rev(lst * 15 - pos.ra);

    final alt = math.asin(
      math.sin(_rad(lat)) * math.sin(_rad(pos.dec)) +
          math.cos(_rad(lat)) * math.cos(_rad(pos.dec)) * math.cos(_rad(ha)),
    );
    return _deg(alt);
  }

  _MoonDayEvents _dayEvents(DateTime localDay, double lat, double lon) {
    // Standard altitude for moon rise/set including refraction and parallax.
    const h0 = 0.125;
    final start = DateTime(localDay.year, localDay.month, localDay.day);

    DateTime? rise;
    DateTime? setTime;
    DateTime? upperTransit;
    DateTime? lowerTransit;
    double maxAlt = -90;
    double minAlt = 90;

    const stepMinutes = 5;
    var prevAlt = _altitude(start.toUtc(), lat, lon);
    for (
      var minutes = stepMinutes;
      minutes <= 24 * 60;
      minutes += stepMinutes
    ) {
      final t = start.add(Duration(minutes: minutes));
      final alt = _altitude(t.toUtc(), lat, lon);

      if (rise == null && prevAlt < h0 && alt >= h0) {
        rise = _interpolateCrossing(
          start,
          minutes - stepMinutes,
          minutes,
          prevAlt,
          alt,
          h0,
          lat,
          lon,
        );
      }
      if (setTime == null && prevAlt >= h0 && alt < h0) {
        setTime = _interpolateCrossing(
          start,
          minutes - stepMinutes,
          minutes,
          prevAlt,
          alt,
          h0,
          lat,
          lon,
        );
      }
      if (alt > maxAlt) {
        maxAlt = alt;
        upperTransit = t;
      }
      if (alt < minAlt) {
        minAlt = alt;
        lowerTransit = t;
      }
      prevAlt = alt;
    }

    return _MoonDayEvents(
      rise: rise,
      set: setTime,
      upperTransit: upperTransit,
      lowerTransit: lowerTransit,
    );
  }

  DateTime _interpolateCrossing(
    DateTime start,
    int m0,
    int m1,
    double a0,
    double a1,
    double target,
    double lat,
    double lon,
  ) {
    final frac = (target - a0) / (a1 - a0);
    final minutes = m0 + (m1 - m0) * frac;
    return start.add(Duration(seconds: (minutes * 60).round()));
  }

  List<SolunarPeriod> _solunarPeriods(_MoonDayEvents e) {
    final periods = <SolunarPeriod>[];

    void addMajor(DateTime? center) {
      if (center == null) return;
      periods.add(
        SolunarPeriod(
          start: TimeOfDay.fromDateTime(
            center.subtract(const Duration(hours: 1)),
          ),
          end: TimeOfDay.fromDateTime(center.add(const Duration(hours: 1))),
          isMajor: true,
        ),
      );
    }

    void addMinor(DateTime? center) {
      if (center == null) return;
      periods.add(
        SolunarPeriod(
          start: TimeOfDay.fromDateTime(
            center.subtract(const Duration(minutes: 30)),
          ),
          end: TimeOfDay.fromDateTime(center.add(const Duration(minutes: 30))),
          isMajor: false,
        ),
      );
    }

    addMajor(e.upperTransit);
    addMajor(e.lowerTransit);
    addMinor(e.rise);
    addMinor(e.set);
    return periods;
  }
}

class _MoonDayEvents {
  final DateTime? rise;
  final DateTime? set;
  final DateTime? upperTransit;
  final DateTime? lowerTransit;

  const _MoonDayEvents({
    this.rise,
    this.set,
    this.upperTransit,
    this.lowerTransit,
  });
}
