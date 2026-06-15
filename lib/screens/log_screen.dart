import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/fishing_log.dart';
import '../providers/app_state.dart';
import '../utils/formatting.dart';
import '../widgets/responsive.dart';
import 'add_log_screen.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final logs = state.logs;

    return Scaffold(
      appBar: AppBar(title: const Text('Fishing Log')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddLogScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
      ),
      body: ContentBody(
        child: logs.isEmpty
            ? const _EmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: logs.length,
                itemBuilder: (context, i) => _LogTile(log: logs[i]),
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text('No entries yet'),
          const SizedBox(height: 4),
          Text(
            'Tap "New Entry" to record a trip',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final FishingLog log;
  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('${log.riverName} • ${formatShortDate(log.date)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (log.flyUsed != null && log.flyUsed!.isNotEmpty)
              Text('Fly: ${log.flyUsed}'),
            Text(
              [
                if (log.fishSpecies != null && log.fishSpecies!.isNotEmpty)
                  log.fishSpecies,
                '${log.fishCaught} caught',
                if (log.moonPhase != null) log.moonPhase,
              ].whereType<String>().join(' • '),
            ),
            if (log.notes != null && log.notes!.isNotEmpty)
              Text(log.notes!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => context.read<AppState>().deleteLog(log.id),
        ),
      ),
    );
  }
}
