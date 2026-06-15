import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/fishing_log.dart';
import '../models/moon_info.dart';
import '../models/river.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../utils/formatting.dart';
import '../widgets/responsive.dart';

class AddLogScreen extends StatefulWidget {
  const AddLogScreen({super.key});

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  final _formKey = GlobalKey<FormState>();
  late River _river;
  DateTime _date = DateTime.now();
  final _weather = TextEditingController();
  final _waterLevel = TextEditingController();
  final _fly = TextEditingController();
  final _species = TextEditingController();
  final _count = TextEditingController(text: '0');
  final _length = TextEditingController();
  final _notes = TextEditingController();
  final _picker = ImagePicker();
  final List<Uint8List> _photos = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _river = context.read<AppState>().selectedRiver;
  }

  @override
  void dispose() {
    _weather.dispose();
    _waterLevel.dispose();
    _fly.dispose();
    _species.dispose();
    _count.dispose();
    _length.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    try {
      final picked = await _picker.pickMultiImage(
        maxWidth: 1600,
        imageQuality: 70,
      );
      if (picked.isEmpty) return;
      final bytes = await Future.wait(picked.map((x) => x.readAsBytes()));
      if (mounted) setState(() => _photos.addAll(bytes));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load the selected images: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final state = context.read<AppState>();
    final moon = state.conditions?.moon;

    try {
      final photoIds = _photos.isEmpty
          ? const <String>[]
          : await state.savePhotos(_photos);

      final log = FishingLog(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        riverId: _river.id,
        riverName: _river.name,
        date: _date,
        weather: _weather.text.trim().isEmpty ? null : _weather.text.trim(),
        waterLevel: double.tryParse(_waterLevel.text.replaceAll(',', '.')),
        flyUsed: _fly.text.trim().isEmpty ? null : _fly.text.trim(),
        fishSpecies: _species.text.trim().isEmpty ? null : _species.text.trim(),
        fishCaught: int.tryParse(_count.text) ?? 0,
        fishLengthCm: double.tryParse(_length.text.replaceAll(',', '.')),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        moonPhase: moon?.phase.label,
        moonIllumination: moon?.illumination,
        photoIds: photoIds,
      );

      await state.addLog(log);
      navigator.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save the entry: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Log Entry'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('SAVE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ContentBody(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                initialValue: _river.id,
                decoration: const InputDecoration(labelText: 'River'),
                items: state.rivers
                    .map(
                      (r) => DropdownMenuItem(value: r.id, child: Text(r.name)),
                    )
                    .toList(),
                onChanged: (id) =>
                    setState(() => _river = state.riverService.riverById(id!)),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(formatDate(_date)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2015),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              _field(_weather, 'Weather', hint: 'e.g. Overcast, light rain'),
              _field(
                _waterLevel,
                'Water level (m)',
                keyboard: TextInputType.number,
              ),
              _field(_fly, 'Fly used', hint: 'e.g. BWO Emerger #18'),
              _field(_species, 'Fish species', hint: 'e.g. Brown trout'),
              _field(_count, 'Fish caught', keyboard: TextInputType.number),
              _field(
                _length,
                'Largest fish (cm)',
                keyboard: TextInputType.number,
              ),
              _field(_notes, 'Notes', maxLines: 3),
              const SizedBox(height: 8),
              _PhotoSection(
                photos: _photos,
                onAdd: _pickPhotos,
                onRemove: (i) => setState(() => _photos.removeAt(i)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    String? hint,
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  final List<Uint8List> photos;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 18,
              color: AppTheme.accent,
            ),
            const SizedBox(width: 6),
            Text(
              'Upload Pictures',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < photos.length; i++)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      photos[i],
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: IconButton(
                      tooltip: 'Remove',
                      iconSize: 18,
                      icon: const CircleAvatar(
                        radius: 11,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                      onPressed: () => onRemove(i),
                    ),
                  ),
                ],
              ),
            InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.5),
                  ),
                  color: AppTheme.accent.withValues(alpha: 0.06),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, color: AppTheme.accent),
                    SizedBox(height: 4),
                    Text('Add', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
