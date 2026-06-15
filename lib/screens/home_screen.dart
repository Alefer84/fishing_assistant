import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/hatch.dart';
import '../models/moon_info.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../utils/formatting.dart';
import '../widgets/responsive.dart';
import '../widgets/section_card.dart';
import 'river_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final river = state.selectedRiver;
    final conditions = state.conditions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fishing Assistant'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: state.loading ? null : state.refreshConditions,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ContentBody(
        child: RefreshIndicator(
          onRefresh: state.refreshConditions,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _RiverHeader(),
              const SizedBox(height: 12),
              if (state.loading && conditions == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (conditions != null) ...[
                _ScoreCard(),
                const SizedBox(height: 12),
                _WaterCard(),
                const SizedBox(height: 12),
                _WeatherMoonRow(),
                const SizedBox(height: 12),
                _HatchCard(),
                const SizedBox(height: 12),
                _FliesCard(),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Conditions for ${river.name} • ${formatDate(DateTime.now())}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RiverHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final river = state.selectedRiver;
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppTheme.accent,
          child: Icon(Icons.water, color: Colors.white),
        ),
        title: Text(
          river.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(river.country),
        trailing: TextButton.icon(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const RiverScreen()));
          },
          icon: const Icon(Icons.swap_horiz),
          label: const Text('Change'),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final conditions = context.watch<AppState>().conditions!;
    final score = conditions.score;
    final color = AppTheme.scoreColor(score.total);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 84,
              height: 84,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: CircularProgressIndicator(
                      value: score.total / 10,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${score.total}',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const Text('/10', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fishing Score',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    score.rating,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...score.factors.map(
                    (f) => Row(
                      children: [
                        Icon(
                          f.achieved
                              ? Icons.check_circle
                              : Icons.remove_circle_outline,
                          size: 14,
                          color: f.achieved
                              ? AppTheme.accent
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${f.label} (+${f.points})',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final water = context.watch<AppState>().conditions!.water;
    return SectionCard(
      title: 'Water Conditions',
      icon: Icons.waves,
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(flex: 3, child: SizedBox()),
              Expanded(
                flex: 2,
                child: Text(
                  'Current',
                  textAlign: TextAlign.end,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.grey),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Normal',
                  textAlign: TextAlign.end,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.grey),
                ),
              ),
            ],
          ),
          MetricRow(
            label: 'Flow',
            value: '${water.flowCfs.toStringAsFixed(0)} CFS',
            comparison: '${water.normalFlowCfs.toStringAsFixed(0)} CFS',
          ),
          MetricRow(
            label: 'Level',
            value: '${water.levelMeters.toStringAsFixed(2)} m',
            comparison: '${water.normalLevelMeters.toStringAsFixed(2)} m',
          ),
          if (water.temperatureC != null)
            MetricRow(
              label: 'Temp',
              value: '${water.temperatureC!.toStringAsFixed(1)}°C',
              comparison:
                  '${water.normalTemperatureC?.toStringAsFixed(0) ?? '--'}°C',
            ),
          const Divider(height: 20),
          Row(
            children: [
              Icon(
                water.isFlowNearNormal ? Icons.check_circle : Icons.info,
                size: 16,
                color: water.isFlowNearNormal ? AppTheme.accent : Colors.orange,
              ),
              const SizedBox(width: 6),
              Text(
                'Flow ${signedPercent(water.flowDeviationPercent)} vs normal',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeatherMoonRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final conditions = context.watch<AppState>().conditions!;
    final weather = conditions.weather;
    final moon = conditions.moon;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SectionCard(
              title: 'Weather',
              icon: Icons.cloud,
              child: weather == null
                  ? Text(
                      conditions.weatherError ?? 'Unavailable',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather.temperatureC.toStringAsFixed(0)}°C',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(weather.description),
                        const SizedBox(height: 4),
                        Text(
                          'Wind ${weather.windSpeedKmh.toStringAsFixed(0)} km/h',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SectionCard(
              title: 'Moon',
              icon: Icons.nightlight_round,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(moon.phase.emoji, style: const TextStyle(fontSize: 24)),
                  Text(
                    moon.phase.label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(moon.illumination * 100).toStringAsFixed(0)}% lit',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Full moon ${daysUntil(moon.nextFullMoon)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HatchCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hatches = context.watch<AppState>().conditions!.activeHatches;
    return SectionCard(
      title: "Today's Hatch",
      icon: Icons.bug_report,
      child: hatches.isEmpty
          ? const Text('No notable hatches expected this month.')
          : Column(
              children: hatches
                  .map(
                    (h) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('${h.species} (${h.stage.label})'),
                          ),
                          _ProbabilityChip(h.probability),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _ProbabilityChip extends StatelessWidget {
  final HatchProbability probability;
  const _ProbabilityChip(this.probability);

  @override
  Widget build(BuildContext context) {
    final color = switch (probability) {
      HatchProbability.high => const Color(0xFF2E7D32),
      HatchProbability.medium => const Color(0xFFE9A23B),
      HatchProbability.low => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        probability.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FliesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final flies = context.watch<AppState>().conditions!.recommendedFlies;
    return SectionCard(
      title: 'Recommended Flies',
      icon: Icons.set_meal,
      child: flies.isEmpty
          ? const Text('Match local conditions; try small nymphs.')
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: flies
                  .map(
                    (f) => Chip(
                      label: Text(f),
                      backgroundColor: AppTheme.accent.withValues(alpha: 0.12),
                      side: BorderSide.none,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
