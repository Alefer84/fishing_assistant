import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/river.dart';
import '../providers/app_state.dart';

class RiverScreen extends StatefulWidget {
  const RiverScreen({super.key});

  @override
  State<RiverScreen> createState() => _RiverScreenState();
}

class _RiverScreenState extends State<RiverScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final results = state.riverService.search(_query);
    final favorites =
        results.where((r) => state.isFavorite(r)).toList();
    final others = results.where((r) => !state.isFavorite(r)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Select River')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search rivers',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (favorites.isNotEmpty) ...[
                  const _SectionLabel('Favorites'),
                  ...favorites.map((r) => _RiverTile(river: r)),
                ],
                if (others.isNotEmpty) ...[
                  _SectionLabel(
                      favorites.isEmpty ? 'Rivers' : 'All Rivers'),
                  ...others.map((r) => _RiverTile(river: r)),
                ],
                if (results.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No rivers found')),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: Colors.grey.shade700)),
    );
  }
}

class _RiverTile extends StatelessWidget {
  final River river;
  const _RiverTile({required this.river});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isSelected = state.selectedRiver.id == river.id;
    final isFavorite = state.isFavorite(river);
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.water,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.grey,
      ),
      title: Text(river.name),
      subtitle: Text(river.country),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite ? Colors.amber : Colors.grey,
        ),
        onPressed: () => state.toggleFavorite(river),
      ),
      onTap: () async {
        await state.selectRiver(river);
        if (context.mounted) Navigator.of(context).pop();
      },
    );
  }
}
