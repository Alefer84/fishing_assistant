import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/forecast.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../utils/formatting.dart';
import '../utils/weather_icons.dart';
import '../widgets/responsive.dart';
import '../widgets/section_card.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final conditions = state.conditions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: state.loading ? null : state.refreshConditions,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: conditions == null
          ? const Center(child: CircularProgressIndicator())
          : ContentBody(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _LocationHeader(
                    label: conditions.weatherLocationLabel,
                    latitude: conditions.weatherLatitude,
                    longitude: conditions.weatherLongitude,
                  ),
                  const SizedBox(height: 12),
                  if (conditions.forecast == null)
                    SectionCard(
                      title: 'Forecast',
                      icon: Icons.cloud,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            conditions.forecastError ?? 'Loading forecast…',
                          ),
                        ),
                      ),
                    )
                  else ...[
                    _CurrentCard(forecast: conditions.forecast!),
                    const SizedBox(height: 12),
                    _TodayCard(forecast: conditions.forecast!),
                    const SizedBox(height: 12),
                    _HourlyCard(forecast: conditions.forecast!),
                    const SizedBox(height: 12),
                    _WeeklyCard(forecast: conditions.forecast!),
                  ],
                ],
              ),
            ),
    );
  }
}

class _LocationHeader extends StatelessWidget {
  const _LocationHeader({
    required this.label,
    required this.latitude,
    required this.longitude,
  });

  final String label;
  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Icon(Icons.place, size: 18, color: AppTheme.accent),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${latitude.toStringAsFixed(3)}, '
                '${longitude.toStringAsFixed(3)} • IMGW station',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CurrentCard extends StatelessWidget {
  const _CurrentCard({required this.forecast});

  final Forecast forecast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final hours = forecast.upcomingHours(count: 1, from: now);
    if (hours.isEmpty) return const SizedBox.shrink();
    final h = hours.first;

    return SectionCard(
      title: 'Now',
      icon: Icons.thermostat,
      child: Row(
        children: [
          Icon(
            weatherIcon(h.weatherCode),
            size: 56,
            color: weatherIconColor(h.weatherCode),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${h.temperatureC.toStringAsFixed(0)}°C',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(weatherDescription(h.weatherCode)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _miniStat(
                Icons.umbrella,
                '${h.precipitationProbability}%',
                'rain',
              ),
              const SizedBox(height: 6),
              _miniStat(
                Icons.air,
                '${h.windSpeedKmh.toStringAsFixed(0)} km/h',
                'wind',
              ),
              const SizedBox(height: 6),
              _miniStat(
                Icons.cloud,
                '${h.cloudCoverPercent.toStringAsFixed(0)}%',
                'cloud',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text('$value '),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.forecast});

  final Forecast forecast;

  @override
  Widget build(BuildContext context) {
    final day = forecast.today;
    if (day == null) return const SizedBox.shrink();

    return SectionCard(
      title: 'Today',
      icon: Icons.wb_twilight,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SunStat(
                icon: Icons.wb_sunny_outlined,
                label: 'Sunrise',
                value: formatClock(day.sunrise),
              ),
              _SunStat(
                icon: Icons.nightlight_outlined,
                label: 'Sunset',
                value: formatClock(day.sunset),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SunStat(
                icon: Icons.thermostat,
                label: 'High / Low',
                value:
                    '${day.temperatureMaxC.toStringAsFixed(0)}° / '
                    '${day.temperatureMinC.toStringAsFixed(0)}°',
              ),
              _SunStat(
                icon: Icons.umbrella,
                label: 'Max rain',
                value: '${day.precipitationProbabilityMax}%',
              ),
              _SunStat(
                icon: Icons.air,
                label: 'Max wind',
                value: '${day.windSpeedMaxKmh.toStringAsFixed(0)} km/h',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SunStat extends StatelessWidget {
  const _SunStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: AppTheme.accent),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}

class _HourlyCard extends StatelessWidget {
  const _HourlyCard({required this.forecast});

  final Forecast forecast;

  @override
  Widget build(BuildContext context) {
    final hours = forecast.upcomingHours(count: 24);
    if (hours.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'Hourly (next 24h)',
      icon: Icons.schedule,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 130, child: _HourlyTempChart(hours: hours)),
          const SizedBox(height: 8),
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: hours.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, i) => _HourCell(hour: hours[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourCell extends StatelessWidget {
  const _HourCell({required this.hour});

  final HourlyForecast hour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNight = hour.time.hour < 6 || hour.time.hour >= 21;
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('HH:00').format(hour.time),
            style: theme.textTheme.bodySmall,
          ),
          Icon(
            weatherIcon(hour.weatherCode, isNight: isNight),
            color: weatherIconColor(hour.weatherCode),
          ),
          Text(
            '${hour.temperatureC.toStringAsFixed(0)}°',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop, size: 11, color: Color(0xFF3D8BFD)),
              const SizedBox(width: 2),
              Text(
                '${hour.precipitationProbability}%',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.air, size: 11, color: Colors.grey.shade600),
              const SizedBox(width: 2),
              Text(
                hour.windSpeedKmh.toStringAsFixed(0),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Temperature curve + precipitation-probability bars for the next 24h.
class _HourlyTempChart extends StatelessWidget {
  const _HourlyTempChart({required this.hours});

  final List<HourlyForecast> hours;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _HourlyChartPainter(
        hours: hours,
        lineColor: AppTheme.accent,
        textColor: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
      ),
    );
  }
}

class _HourlyChartPainter extends CustomPainter {
  _HourlyChartPainter({
    required this.hours,
    required this.lineColor,
    required this.textColor,
  });

  final List<HourlyForecast> hours;
  final Color lineColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (hours.isEmpty) return;

    const leftPad = 28.0;
    const topPad = 16.0;
    const bottomPad = 18.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - topPad - bottomPad;

    final temps = hours.map((h) => h.temperatureC).toList();
    var minT = temps.reduce((a, b) => a < b ? a : b);
    var maxT = temps.reduce((a, b) => a > b ? a : b);
    if (maxT - minT < 1) {
      maxT += 1;
      minT -= 1;
    }

    double xFor(int i) =>
        leftPad + (hours.length == 1 ? 0 : chartW * i / (hours.length - 1));
    double yFor(double t) => topPad + chartH * (1 - (t - minT) / (maxT - minT));

    // Precipitation-probability bars (light blue) behind the line.
    final barPaint = Paint()..color = const Color(0x333D8BFD);
    final barW = chartW / hours.length * 0.6;
    for (var i = 0; i < hours.length; i++) {
      final p = hours[i].precipitationProbability / 100.0;
      if (p <= 0) continue;
      final h = chartH * p;
      final x = xFor(i);
      canvas.drawRect(
        Rect.fromLTWH(x - barW / 2, topPad + chartH - h, barW, h),
        barPaint,
      );
    }

    // Temperature line.
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    for (var i = 0; i < hours.length; i++) {
      final x = xFor(i);
      final y = yFor(temps[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = lineColor;
    for (var i = 0; i < hours.length; i += 3) {
      canvas.drawCircle(Offset(xFor(i), yFor(temps[i])), 2.5, dotPaint);
    }

    // Min/max temp labels on the left axis.
    _label(canvas, '${maxT.toStringAsFixed(0)}°', const Offset(0, topPad - 6));
    _label(
      canvas,
      '${minT.toStringAsFixed(0)}°',
      Offset(0, topPad + chartH - 6),
    );

    // A few time labels along the bottom.
    for (var i = 0; i < hours.length; i += 6) {
      _label(
        canvas,
        DateFormat('HH:00').format(hours[i].time),
        Offset(xFor(i) - 12, size.height - bottomPad + 2),
      );
    }
  }

  void _label(Canvas canvas, String text, Offset offset) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: textColor, fontSize: 10),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _HourlyChartPainter old) => old.hours != hours;
}

class _WeeklyCard extends StatelessWidget {
  const _WeeklyCard({required this.forecast});

  final Forecast forecast;

  @override
  Widget build(BuildContext context) {
    final days = forecast.daily;
    if (days.isEmpty) return const SizedBox.shrink();

    final overallMin = days
        .map((d) => d.temperatureMinC)
        .reduce((a, b) => a < b ? a : b);
    final overallMax = days
        .map((d) => d.temperatureMaxC)
        .reduce((a, b) => a > b ? a : b);

    return SectionCard(
      title: '7-Day Forecast',
      icon: Icons.calendar_month,
      child: Column(
        children: [
          for (final d in days)
            _DayRow(day: d, overallMin: overallMin, overallMax: overallMax),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.overallMin,
    required this.overallMax,
  });

  final DailyForecast day;
  final double overallMin;
  final double overallMax;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = DateUtils.isSameDay(day.date, DateTime.now());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              isToday ? 'Today' : DateFormat('EEE').format(day.date),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Icon(
            weatherIcon(day.weatherCode),
            color: weatherIconColor(day.weatherCode),
            size: 22,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 42,
            child: Row(
              children: [
                const Icon(
                  Icons.water_drop,
                  size: 11,
                  color: Color(0xFF3D8BFD),
                ),
                const SizedBox(width: 2),
                Text(
                  '${day.precipitationProbabilityMax}%',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: _RangeBar(
              min: day.temperatureMinC,
              max: day.temperatureMaxC,
              overallMin: overallMin,
              overallMax: overallMax,
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeBar extends StatelessWidget {
  const _RangeBar({
    required this.min,
    required this.max,
    required this.overallMin,
    required this.overallMax,
  });

  final double min;
  final double max;
  final double overallMin;
  final double overallMax;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final span = (overallMax - overallMin).clamp(1, double.infinity);
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            '${min.toStringAsFixed(0)}°',
            textAlign: TextAlign.end,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final left = w * (min - overallMin) / span;
              final barW = (w * (max - min) / span).clamp(6.0, w);
              return Stack(
                children: [
                  Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Positioned(
                    left: left,
                    child: Container(
                      height: 6,
                      width: barW,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6CB4EE), Color(0xFFF5A623)],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 28,
          child: Text(
            '${max.toStringAsFixed(0)}°',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
