import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../models/timer_model.dart';
import '../models/alarm_sound.dart';
import '../utils/app_theme.dart';

class CreateTimerScreen extends StatefulWidget {
  final TimerModel? timer;

  const CreateTimerScreen({super.key, this.timer});

  @override
  State<CreateTimerScreen> createState() => _CreateTimerScreenState();
}

class _CreateTimerScreenState extends State<CreateTimerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  int _hours = 0;
  int _minutes = 5;
  int _seconds = 0;
  Color _selectedColor = AppTheme.timerColors[0];
  AlarmSound _selectedAlarm = AlarmSound.bell;
  bool _vibrationEnabled = true;

  bool get isEditing => widget.timer != null;

  @override
  void initState() {
    super.initState();
    if (widget.timer != null) {
      _nameController.text = widget.timer!.name;
      _hours = widget.timer!.durationSeconds ~/ 3600;
      _minutes = (widget.timer!.durationSeconds % 3600) ~/ 60;
      _seconds = widget.timer!.durationSeconds % 60;
      _selectedColor = widget.timer!.color;
      _selectedAlarm = widget.timer!.alarmSound;
      _vibrationEnabled = widget.timer!.vibrationEnabled;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Timer' : 'New Timer'),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareTimer,
              tooltip: 'Share',
            ),
          TextButton(
            onPressed: _saveTimer,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Timer Name',
                hintText: 'Enter timer name',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Duration',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DurationPicker(
                    label: 'Hours',
                    value: _hours,
                    maxValue: 23,
                    onChanged: (v) => setState(() => _hours = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DurationPicker(
                    label: 'Minutes',
                    value: _minutes,
                    maxValue: 59,
                    onChanged: (v) => setState(() => _minutes = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DurationPicker(
                    label: 'Seconds',
                    value: _seconds,
                    maxValue: 59,
                    onChanged: (v) => setState(() => _seconds = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppTheme.timerColors.map((color) {
                final isSelected = _selectedColor.value == color.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Alarm Sound',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AlarmSound.values.map((alarm) {
                final isSelected = _selectedAlarm == alarm;
                return ChoiceChip(
                  label: Text(alarm.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedAlarm = alarm);
                  },
                  selectedColor: _selectedColor.withValues(alpha: 0.3),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Vibration'),
              subtitle: const Text('Vibrate when timer ends'),
              value: _vibrationEnabled,
              onChanged: (value) => setState(() => _vibrationEnabled = value),
              secondary: const Icon(Icons.vibration),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEditing ? 'Update Timer' : 'Create Timer',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareTimer() {
    final totalSeconds = (_hours * 3600) + (_minutes * 60) + _seconds;
    final shareData =
        'TIMER|${_nameController.text}|$totalSeconds|${_selectedColor.toARGB32()}|${_selectedAlarm.name}|$_vibrationEnabled';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Copy this code to share:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                shareData,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: shareData));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard!')),
              );
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _saveTimer() {
    if (!_formKey.currentState!.validate()) return;
    final totalSeconds = (_hours * 3600) + (_minutes * 60) + _seconds;
    if (totalSeconds == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a duration')),
      );
      return;
    }
    final provider = context.read<TimerProvider>();
    if (isEditing) {
      provider.updateTimer(widget.timer!.copyWith(
        name: _nameController.text,
        durationSeconds: totalSeconds,
        remainingSeconds: totalSeconds,
        color: _selectedColor,
        alarmSound: _selectedAlarm,
        vibrationEnabled: _vibrationEnabled,
      ));
    } else {
      provider.addTimer(
        name: _nameController.text,
        durationSeconds: totalSeconds,
        colorValue: _selectedColor.value,
        alarmSound: _selectedAlarm,
        vibrationEnabled: _vibrationEnabled,
      );
    }
    Navigator.pop(context);
  }
}

class _DurationPicker extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const _DurationPicker({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Container(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: value > 0 ? () => onChanged(value - 1) : null,
                    borderRadius: BorderRadius.circular(6),
                    child: const SizedBox(
                      height: 32,
                      width: 32,
                      child: Icon(Icons.remove, size: 20),
                    ),
                  ),
                  const SizedBox(width: 2),
                  SizedBox(
                    width: 28,
                    child: Text(
                      value.toString().padLeft(2, '0'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  InkWell(
                    onTap: value < maxValue ? () => onChanged(value + 1) : null,
                    borderRadius: BorderRadius.circular(6),
                    child: const SizedBox(
                      height: 32,
                      width: 32,
                      child: Icon(Icons.add, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
