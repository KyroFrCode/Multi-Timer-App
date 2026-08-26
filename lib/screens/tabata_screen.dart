import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/tabata_sequence.dart';
import '../models/tabata_preset.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';

class TabataScreen extends StatefulWidget {
  const TabataScreen({super.key});

  @override
  State<TabataScreen> createState() => _TabataScreenState();
}

class _TabataScreenState extends State<TabataScreen>
    with SingleTickerProviderStateMixin {
  List<TabataSequence> _sequences = [];
  bool _isRunning = false;
  int _currentStep = 0;
  int _remainingSeconds = 0;
  bool _isPaused = false;
  Timer? _timer;
  TabataSequence? _activeSequence;
  TabataCategory _selectedCategory = TabataCategory.workout;

  @override
  void initState() {
    super.initState();
    _loadSequences();
  }

  Future<void> _loadSequences() async {
    final storage = StorageService();
    await storage.init();
    final presets = await storage.loadTabataPresets();
    setState(() {
      _sequences = presets.map((p) => TabataSequence.fromPreset(p)).toList();
    });
  }

  Future<void> _saveSequences() async {
    final storage = StorageService();
    await storage.init();
    await storage
        .saveTabataPresets(_sequences.map((s) => s.toPreset()).toList());
  }

  void _startSequence(TabataSequence seq) {
    setState(() {
      _activeSequence = seq;
      _currentStep = 0;
      _isRunning = true;
      _isPaused = false;
      _remainingSeconds = seq.steps[0].durationSeconds;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_isPaused) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _nextStep();
      }
    });
  }

  void _nextStep() {
    if (_currentStep < _activeSequence!.steps.length - 1) {
      setState(() {
        _currentStep++;
        _remainingSeconds =
            _activeSequence!.steps[_currentStep].durationSeconds;
      });
    } else {
      _stopSequence();
      _showCompletionDialog();
    }
  }

  void _stopSequence() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _activeSequence = null;
    });
  }

  void _pauseSequence() {
    setState(() => _isPaused = !_isPaused);
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete!'),
        content: const Text('Great job! You finished all steps.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _CreateSequenceDialog(
        initialCategory: _selectedCategory,
        onSave: (seq) {
          setState(() => _sequences.add(seq));
          _saveSequences();
        },
      ),
    );
  }

  void _editSequence(TabataSequence seq) {
    showDialog(
      context: context,
      builder: (ctx) => _CreateSequenceDialog(
        initial: seq,
        initialCategory: _selectedCategory,
        onSave: (sequence) {
          setState(() {
            final idx = _sequences.indexWhere((s) => s.id == seq.id);
            if (idx != -1) _sequences[idx] = sequence;
          });
          _saveSequences();
        },
      ),
    );
  }

  void _deleteSequence(TabataSequence seq) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Delete "${seq.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _sequences.removeWhere((s) => s.id == seq.id));
              _saveSequences();
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _shareSequence(TabataSequence seq) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Share'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Copy this code:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                seq.toShareString(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: seq.toShareString()));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied!')),
              );
            },
            child: const Text('Copy'),
          ),
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _importSequence() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Paste code here'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final seq = TabataSequence.fromShareString(ctrl.text);
              if (seq != null) {
                setState(() => _sequences.add(seq));
                _saveSequences();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Imported!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid code')),
                );
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isRunning && _activeSequence != null) {
      return _buildActiveView(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabata'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _showCreateDialog),
          IconButton(
              icon: const Icon(Icons.import_export),
              onPressed: _importSequence),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<TabataCategory>(
              segments: const [
                ButtonSegment(
                  value: TabataCategory.workout,
                  label: Text('Workout'),
                  icon: Icon(Icons.fitness_center),
                ),
                ButtonSegment(
                  value: TabataCategory.cooking,
                  label: Text('Cooking'),
                  icon: Icon(Icons.restaurant),
                ),
              ],
              selected: {_selectedCategory},
              onSelectionChanged: (s) =>
                  setState(() => _selectedCategory = s.first),
            ),
          ),
          Expanded(
            child: _sequences.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center,
                            size: 80,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        const Text('No sequences yet'),
                        const SizedBox(height: 8),
                        const Text('Tap + to create one'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sequences.length,
                    itemBuilder: (context, index) {
                      final seq = _sequences[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: seq.color,
                            child: Text('${seq.steps.length}',
                                style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(seq.name),
                          subtitle: Text(seq.totalDuration),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.play_arrow, size: 32),
                                onPressed: () => _startSequence(seq),
                              ),
                              PopupMenuButton(
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 8),
                                        Text('Edit')
                                      ])),
                                  const PopupMenuItem(
                                      value: 'share',
                                      child: Row(children: [
                                        Icon(Icons.share),
                                        SizedBox(width: 8),
                                        Text('Share')
                                      ])),
                                  const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(children: [
                                        Icon(Icons.delete,
                                            color: AppTheme.errorColor),
                                        SizedBox(width: 8),
                                        Text('Delete',
                                            style: TextStyle(
                                                color: AppTheme.errorColor)),
                                      ])),
                                ],
                                onSelected: (v) {
                                  if (v == 'edit') _editSequence(seq);
                                  if (v == 'share') _shareSequence(seq);
                                  if (v == 'delete') _deleteSequence(seq);
                                },
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                children:
                                    seq.steps.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final step = entry.value;
                                  return ListTile(
                                    leading: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: step.isRest
                                          ? Colors.orange.withValues(alpha: 0.3)
                                          : Colors.green.withValues(alpha: 0.3),
                                      child: Text('${i + 1}',
                                          style: TextStyle(
                                              color: step.isRest
                                                  ? Colors.orange
                                                  : Colors.green,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    title: Text(step.name),
                                    subtitle:
                                        Text(step.isRest ? 'Rest' : 'Work'),
                                    trailing: Text('${step.durationSeconds}s'),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveView(BuildContext context) {
    final step = _activeSequence!.steps[_currentStep];
    final color = step.isRest ? Colors.orange : Colors.green;
    final totalDuration = _activeSequence!.steps[_currentStep].durationSeconds;
    final progress =
        totalDuration > 0 ? 1 - (_remainingSeconds / totalDuration) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_activeSequence!.name),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                step.name.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                step.isRest ? 'REST' : 'WORK',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: color.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    Text(
                      '$_remainingSeconds',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontWeight: FontWeight.bold, color: color),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                  'Step ${_currentStep + 1} / ${_activeSequence!.steps.length}',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pauseSequence,
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                    label: Text(_isPaused ? 'Resume' : 'Pause'),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _stopSequence,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateSequenceDialog extends StatefulWidget {
  final TabataSequence? initial;
  final TabataCategory initialCategory;
  final Function(TabataSequence) onSave;

  const _CreateSequenceDialog({
    this.initial,
    required this.initialCategory,
    required this.onSave,
  });

  @override
  State<_CreateSequenceDialog> createState() => _CreateSequenceDialogState();
}

class _CreateSequenceDialogState extends State<_CreateSequenceDialog> {
  final _nameController = TextEditingController();
  List<TabataStep> _steps = [];
  int _stepCount = 2;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _nameController.text = widget.initial!.name;
      _steps = List.from(widget.initial!.steps);
      _stepCount = _steps.length;
    } else {
      _steps = [
        TabataStep(
            id: const Uuid().v4(),
            name: 'Work 1',
            durationSeconds: 20,
            isRest: false),
        TabataStep(
            id: const Uuid().v4(),
            name: 'Rest 1',
            durationSeconds: 10,
            isRest: true),
      ];
    }
  }

  void _updateStepCount(int count) {
    setState(() {
      _stepCount = count;
      while (_steps.length < count) {
        final isRest = _steps.length % 2 == 1;
        _steps.add(TabataStep(
          id: const Uuid().v4(),
          name: isRest
              ? 'Rest ${(_steps.length ~/ 2) + 1}'
              : 'Work ${(_steps.length ~/ 2) + 1}',
          durationSeconds: isRest ? 10 : 20,
          isRest: isRest,
        ));
      }
      if (_steps.length > count) {
        _steps = _steps.sublist(0, count);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWorkout = widget.initialCategory == TabataCategory.workout;

    return AlertDialog(
      title: Text(widget.initial != null ? 'Edit Sequence' : 'New Sequence'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Name', hintText: 'My sequence'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Steps: $_stepCount', style: theme.textTheme.bodyMedium),
                  Expanded(
                    child: Slider(
                      value: _stepCount.toDouble(),
                      min: 2,
                      max: 20,
                      divisions: 18,
                      label: '$_stepCount steps',
                      onChanged: (v) => _updateStepCount(v.toInt()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._steps.asMap().entries.map((entry) {
                final i = entry.key;
                final step = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          step.isRest
                              ? Icons.pause_circle
                              : (isWorkout
                                  ? Icons.fitness_center
                                  : Icons.restaurant),
                          color: step.isRest ? Colors.orange : Colors.green,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: TextEditingController(text: step.name),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (v) => setState(
                                () => _steps[i] = _steps[i].copyWith(name: v)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.remove, size: 20),
                          onPressed: step.durationSeconds > 5
                              ? () => setState(() => _steps[i] = _steps[i]
                                  .copyWith(
                                      durationSeconds:
                                          step.durationSeconds - 5))
                              : null,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '${step.durationSeconds}s',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () => setState(() => _steps[i] = _steps[i]
                              .copyWith(
                                  durationSeconds: step.durationSeconds + 5)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        if (_stepCount > 2)
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => _updateStepCount(_stepCount - 1),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _updateStepCount(_stepCount + 1),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Step'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_nameController.text.isEmpty || _steps.length < 2) return;
            final seq = TabataSequence(
              id: widget.initial?.id ?? const Uuid().v4(),
              name: _nameController.text,
              steps: _steps,
              color: AppTheme
                  .timerColors[_steps.length % AppTheme.timerColors.length],
            );
            widget.onSave(seq);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
