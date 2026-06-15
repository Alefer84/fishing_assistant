import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/moon_info.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../utils/formatting.dart';
import '../widgets/section_card.dart';

class MoonScreen extends StatelessWidget {
  const MoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final conditions = state.conditions;

    return Scaffold(
      appBar: AppBar(title: const Text('Moon & Solunar')),
      body: conditions == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _MoonSummary(conditions.moon),
                const SizedBox(height: 12),
                _RiseSet(conditions.moon),
                const SizedBox(height: 12),
                _Solunar(conditions.moon),
                const SizedBox(height: 12),
                _MonthlyCalendar(),
              ],
            ),
    );
  }
}

class _MoonSummary extends StatelessWidget {
  final MoonInfo moon;
  const _MoonSummary(this.moon);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(moon.phase.emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(moon.phase.label,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                      'Illumination ${(moon.illumination * 100).toStringAsFixed(0)}%'),
                  Text('Moon age ${moon.ageDays.toStringAsFixed(1)} days'),
                  Text('Next full moon ${daysUntil(moon.nextFullMoon)}'),
                  Text('Next new moon ${daysUntil(moon.nextNewMoon)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiseSet extends StatelessWidget {
  final MoonInfo moon;
  const _RiseSet(this.moon);

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Moonrise / Moonset',
      icon: Icons.swap_vert,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TimeBlock(
              icon: Icons.arrow_upward,
              label: 'Moonrise',
              time: formatClock(moon.moonrise)),
          _TimeBlock(
              icon: Icons.arrow_downward,
              label: 'Moonset',
              time: formatClock(moon.moonset)),
        ],
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  const _TimeBlock(
      {required this.icon, required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary),
        const SizedBox(height: 4),
        Text(time,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _Solunar extends StatelessWidget {
  final MoonInfo moon;
  const _Solunar(this.moon);

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Solunar Activity',
      icon: Icons.access_time_filled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Major Periods',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppTheme.primary)),
          ...moon.majorPeriods.map((p) => _PeriodRow(p)),
          if (moon.majorPeriods.isEmpty) const Text('--'),
          const SizedBox(height: 12),
          Text('Minor Periods',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppTheme.accent)),
          ...moon.minorPeriods.map((p) => _PeriodRow(p)),
          if (moon.minorPeriods.isEmpty) const Text('--'),
          const Divider(height: 24),
          Text(
            'Major periods (moon overhead/underfoot) tend to bring the '
            'strongest feeding activity; minor periods occur around '
            'moonrise and moonset.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  final SolunarPeriod period;
  const _PeriodRow(this.period);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(period.isMajor ? Icons.star : Icons.star_half,
              size: 16,
              color: period.isMajor ? AppTheme.primary : AppTheme.accent),
          const SizedBox(width: 8),
          Text(
              '${formatTimeOfDay(period.start)} – ${formatTimeOfDay(period.end)}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MonthlyCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final moonService = context.read<AppState>().moonService;
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = DateTime(now.year, now.month, 1).weekday; // Mon=1

    final cells = <Widget>[];
    for (var i = 1; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(now.year, now.month, day);
      final phase = moonService.phaseForDate(date);
      final isToday = day == now.day;
      cells.add(Container(
        decoration: isToday
            ? BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$day', style: const TextStyle(fontSize: 11)),
            Text(phase.emoji, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ));
    }

    return SectionCard(
      title: 'Moon Calendar',
      icon: Icons.calendar_month,
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.8,
            children: const [
              _Dow('Mon'),
              _Dow('Tue'),
              _Dow('Wed'),
              _Dow('Thu'),
              _Dow('Fri'),
              _Dow('Sat'),
              _Dow('Sun'),
            ],
          ),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.8,
            children: cells,
          ),
        ],
      ),
    );
  }
}

class _Dow extends StatelessWidget {
  final String label;
  const _Dow(this.label);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: Colors.grey)),
    );
  }
}
