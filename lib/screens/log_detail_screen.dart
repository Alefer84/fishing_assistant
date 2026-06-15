import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/fishing_log.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../utils/formatting.dart';
import '../widgets/responsive.dart';
import '../widgets/section_card.dart';

class LogDetailScreen extends StatelessWidget {
  const LogDetailScreen({super.key, required this.log});

  final FishingLog log;

  @override
  Widget build(BuildContext context) {
    final details = <_Detail>[
      _Detail('River', log.riverName),
      _Detail('Date', formatDate(log.date)),
      if (log.weather != null && log.weather!.isNotEmpty)
        _Detail('Weather', log.weather!),
      if (log.waterLevel != null) _Detail('Water level', '${log.waterLevel} m'),
      if (log.flyUsed != null && log.flyUsed!.isNotEmpty)
        _Detail('Fly used', log.flyUsed!),
      if (log.fishSpecies != null && log.fishSpecies!.isNotEmpty)
        _Detail('Species', log.fishSpecies!),
      _Detail('Fish caught', '${log.fishCaught}'),
      if (log.fishLengthCm != null)
        _Detail('Largest fish', '${log.fishLengthCm} cm'),
      if (log.moonPhase != null) _Detail('Moon', log.moonPhase!),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${log.riverName} • ${formatShortDate(log.date)}'),
      ),
      body: ContentBody(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionCard(
              title: 'Trip Details',
              icon: Icons.info_outline,
              child: Column(
                children: [
                  for (final d in details)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              d.label,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              d.value,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (log.notes != null && log.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              SectionCard(
                title: 'Notes',
                icon: Icons.notes,
                child: Text(log.notes!),
              ),
            ],
            const SizedBox(height: 12),
            SectionCard(
              title: 'Pictures',
              icon: Icons.photo_library_outlined,
              child: log.photoIds.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No pictures for this entry.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : _PhotoGrid(photoIds: log.photoIds),
            ),
          ],
        ),
      ),
    );
  }
}

class _Detail {
  final String label;
  final String value;
  const _Detail(this.label, this.value);
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.photoIds});

  final List<String> photoIds;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final id in photoIds)
          FutureBuilder<Uint8List?>(
            future: state.loadPhoto(id),
            builder: (context, snapshot) {
              final bytes = snapshot.data;
              if (bytes == null) {
                return Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return GestureDetector(
                onTap: () => _openViewer(context, bytes),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    bytes,
                    width: 104,
                    height: 104,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _openViewer(BuildContext context, Uint8List bytes) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(child: Image.memory(bytes)),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
