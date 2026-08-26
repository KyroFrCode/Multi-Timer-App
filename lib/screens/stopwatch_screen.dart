import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stopwatch_provider.dart';
import '../models/stopwatch_model.dart';
import '../utils/app_theme.dart';
import '../widgets/stopwatch_display.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.timer), text: 'Chronometers'),
            Tab(icon: Icon(Icons.folder), text: 'Groups'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _StopwatchList(),
          const _StopwatchGroupList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_currentTab == 1) {
            _showCreateGroupDialog(context);
          } else {
            _showCreateDialog(context);
          }
        },
        icon: Icon(_currentTab == 1 ? Icons.folder : Icons.add),
        label: Text(_currentTab == 1 ? 'New Group' : 'New Stopwatch'),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Stopwatch'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'My stopwatch',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (nameController.text.isEmpty) return;
              context
                  .read<StopwatchProvider>()
                  .addStopwatch(nameController.text);
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Group'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Group Name',
            hintText: 'My stopwatch group',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (nameController.text.isEmpty) return;
              context.read<StopwatchProvider>().addGroup(nameController.text);
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _StopwatchList extends StatelessWidget {
  const _StopwatchList();

  @override
  Widget build(BuildContext context) {
    return Consumer<StopwatchProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.stopwatches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined,
                    size: 80,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                const Text('No stopwatches yet'),
                const SizedBox(height: 8),
                const Text('Tap + to create one'),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.stopwatches.length,
          itemBuilder: (context, index) {
            final sw = provider.stopwatches[index];
            return _StopwatchCard(stopwatch: sw);
          },
        );
      },
    );
  }
}

class _StopwatchCard extends StatelessWidget {
  final StopwatchModel stopwatch;

  const _StopwatchCard({required this.stopwatch});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<StopwatchProvider>();
    return Dismissible(
      key: Key(stopwatch.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          provider.deleteStopwatch(stopwatch.id);
          return false;
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: RepaintBoundary(
        child: Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      stopwatch.isRunning ? Colors.green : Colors.grey,
                  child: const Icon(Icons.timer, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          stopwatch.name,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    stopwatch.isRunning ? Colors.green : null,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      RepaintBoundary(
                        child: StopwatchDisplay(stopwatch: stopwatch),
                      ),
                    ],
                  ),
                ),
                if (stopwatch.groupId != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(Icons.folder,
                        size: 14, color: AppTheme.primaryColor),
                  ),
                IconButton(
                  icon: Icon(
                      stopwatch.isRunning ? Icons.stop : Icons.play_arrow,
                      size: 28),
                  onPressed: () {
                    if (stopwatch.isRunning) {
                      provider.stopStopwatch(stopwatch.id);
                    } else {
                      provider.startStopwatch(stopwatch.id);
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 22),
                  onPressed: () => provider.resetStopwatch(stopwatch.id),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'group',
                      child: Row(children: [
                        const Icon(Icons.folder, size: 20),
                        const SizedBox(width: 8),
                        Text(stopwatch.groupId != null
                            ? 'Remove from group'
                            : 'Add to group'),
                      ]),
                    ),
                  ],
                  onSelected: (v) {
                    if (v == 'group') _showGroupDialog(context, stopwatch);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGroupDialog(BuildContext context, StopwatchModel sw) {
    final provider = context.read<StopwatchProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add to Group'),
        content: provider.groups.isEmpty
            ? const Text('No groups yet. Create one in the Groups tab.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: provider.groups.map((group) {
                  final isInGroup = group.stopwatchIds.contains(sw.id);
                  return ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(group.name),
                    trailing: Icon(isInGroup ? Icons.check : Icons.add),
                    onTap: () {
                      if (isInGroup) {
                        provider.removeStopwatchFromGroup(sw.id, group.id);
                      } else {
                        provider.addStopwatchToGroup(sw.id, group.id);
                      }
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
              ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _StopwatchGroupList extends StatelessWidget {
  const _StopwatchGroupList();

  @override
  Widget build(BuildContext context) {
    return Consumer<StopwatchProvider>(
      builder: (context, provider, child) {
        if (provider.groups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_outlined,
                    size: 80,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                const Text('No groups yet'),
                const SizedBox(height: 8),
                const Text('Tap + to create a group'),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.groups.length,
          itemBuilder: (context, index) {
            final group = provider.groups[index];
            final groupSws = provider.getStopwatchesInGroup(group.id);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text('${groupSws.length}',
                      style: const TextStyle(color: Colors.white)),
                ),
                title: Text(group.name),
                subtitle: Text(
                    '${groupSws.length} stopwatch${groupSws.length != 1 ? 's' : ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        groupSws.any((s) => s.isRunning)
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 32,
                      ),
                      onPressed: () {
                        if (groupSws.any((s) => s.isRunning)) {
                          provider.stopGroup(group.id);
                        } else {
                          provider.startGroup(group.id);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => provider.resetGroup(group.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteDialog(context, group),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: groupSws.map((sw) {
                        return RepaintBoundary(
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  sw.isRunning ? Colors.green : Colors.grey,
                              child: const Icon(Icons.timer,
                                  size: 16, color: Colors.white),
                            ),
                            title: Text(sw.name),
                            trailing: StopwatchDisplay(stopwatch: sw),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, StopwatchGroup group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text('Delete "${group.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<StopwatchProvider>().deleteGroup(group.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
