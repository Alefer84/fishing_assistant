import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/fishing_log.dart';
import '../models/moon_info.dart';
import '../models/river.dart';
import '../providers/app_state.dart';
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AppState>();
    final moon = state.conditions?.moon;

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
    );

    await state.addLog(log);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Log Entry'),
        actions: [
          TextButton(
            onPressed: _save,
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
