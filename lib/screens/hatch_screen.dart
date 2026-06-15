import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/hatch.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../widgets/responsive.dart';
import '../widgets/section_card.dart';

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

class HatchScreen extends StatefulWidget {
  const HatchScreen({super.key});

  @override
  State<HatchScreen> createState() => _HatchScreenState();
}

class _HatchScreenState extends State<HatchScreen> {
  int _month = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final river = state.selectedRiver;
    final hatches = state.hatchService.activeHatches(river.id, _month);

    return Scaffold(
      appBar: AppBar(title: Text('Hatch Calendar • ${river.name}')),
      body: ContentBody(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 12,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final month = i + 1;
                  final selected = month == _month;
                  return ChoiceChip(
                    label: Text(_monthNames[i]),
                    selected: selected,
                    onSelected: (_) => setState(() => _month = month),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Likely Hatches • ${_monthNames[_month - 1]}',
              icon: Icons.bug_report,
              child: hatches.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No notable hatches expected this month.'),
                    )
                  : Column(
                      children: [
                        _HeaderRow(),
                        const Divider(),
                        ...hatches.map((h) => _HatchRow(h)),
                      ],
                    ),
            ),
            const SizedBox(height: 12),
            if (hatches.isNotEmpty)
              SectionCard(
                title: 'Suggested Flies',
                icon: Icons.set_meal,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.hatchService
                      .recommendedFlies(river.id, _month)
                      .map(
                        (f) => Chip(
                          label: Text(f),
                          backgroundColor: AppTheme.accent.withValues(
                            alpha: 0.12,
                          ),
                          side: BorderSide.none,
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: Colors.grey);
    return Row(
      children: [
        Expanded(flex: 4, child: Text('Species', style: style)),
        Expanded(flex: 3, child: Text('Stage', style: style)),
        Expanded(
          flex: 3,
          child: Text('Probability', style: style, textAlign: TextAlign.end),
        ),
      ],
    );
  }
}

class _HatchRow extends StatelessWidget {
  final Hatch hatch;
  const _HatchRow(this.hatch);

  @override
  Widget build(BuildContext context) {
    final color = switch (hatch.probability) {
      HatchProbability.high => const Color(0xFF2E7D32),
      HatchProbability.medium => const Color(0xFFE9A23B),
      HatchProbability.low => Colors.grey,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(hatch.species)),
          Expanded(flex: 3, child: Text(hatch.stage.label)),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                hatch.probability.label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
