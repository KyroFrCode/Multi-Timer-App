import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../models/timer_group.dart';
import '../models/timer_model.dart';
import '../utils/app_theme.dart';

class CreateGroupScreen extends StatefulWidget {
  final TimerGroup? group;

  const CreateGroupScreen({super.key, this.group});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  List<String> _selectedTimerIds = [];

  bool get isEditing => widget.group != null;

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      _nameController.text = widget.group!.name;
      _selectedTimerIds = List.from(widget.group!.timerIds);
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
        title: Text(isEditing ? 'Edit Group' : 'New Group'),
        actions: [
          TextButton(
            onPressed: _saveGroup,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter group name',
                prefixIcon: Icon(Icons.folder_outlined),
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
              'Select Timers',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose timers to add to this group',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 16),
            Consumer<TimerProvider>(
              builder: (context, provider, child) {
                final availableTimers = provider.timers
                    .where((t) =>
                        t.groupId == null || widget.group?.timerIds.contains(t.id) == true)
                    .toList();

                if (availableTimers.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.timer_off_outlined,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No timers available',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create some timers first',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: availableTimers.map((timer) {
                    final isSelected = _selectedTimerIds.contains(timer.id);
                    return _TimerSelectionTile(
                      timer: timer,
                      isSelected: isSelected,
                      onChanged: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTimerIds.add(timer.id);
                          } else {
                            _selectedTimerIds.remove(timer.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveGroup() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TimerProvider>();

    if (isEditing) {
      final updatedGroup = widget.group!.copyWith(
        name: _nameController.text,
        timerIds: _selectedTimerIds,
      );
      
      final oldTimerIds = widget.group!.timerIds;
      final removedTimerIds = oldTimerIds.where((id) => !_selectedTimerIds.contains(id));
      
      for (var timerId in removedTimerIds) {
        provider.removeTimerFromGroup(timerId, widget.group!.id);
      }
      
      for (var timerId in _selectedTimerIds) {
        if (!oldTimerIds.contains(timerId)) {
          provider.addTimerToGroup(timerId, widget.group!.id);
        }
      }
      
      provider.updateGroup(updatedGroup);
    } else {
      provider.addGroup(_nameController.text).then((_) {
        final newGroup = provider.groups.last;
        for (var timerId in _selectedTimerIds) {
          provider.addTimerToGroup(timerId, newGroup.id);
        }
      });
    }

    Navigator.pop(context);
  }
}

class _TimerSelectionTile extends StatelessWidget {
  final TimerModel timer;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const _TimerSelectionTile({
    required this.timer,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) => onChanged(value ?? false),
        title: Text(timer.name),
        subtitle: Text(timer.formattedDuration),
        secondary: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: timer.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        activeColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
