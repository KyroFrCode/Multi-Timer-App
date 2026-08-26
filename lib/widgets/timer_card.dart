import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../models/timer_model.dart';
import '../utils/app_theme.dart';

class TimerCard extends StatelessWidget {
  final TimerModel timer;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool compact;

  const TimerCard({
    super.key,
    required this.timer,
    this.onDelete,
    this.onEdit,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(timer.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          onDelete?.call();
          return false;
        } else if (direction == DismissDirection.startToEnd) {
          onEdit?.call();
          return false;
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.edit, color: Colors.white),
            SizedBox(width: 8),
            Text('Edit',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Delete',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      child: Card(
        margin: EdgeInsets.only(bottom: compact ? 8 : 16),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: compact ? 50 : 60,
                decoration: BoxDecoration(
                  color: timer.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            timer.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (timer.groupId != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'In Group',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timer.formattedTime,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                color: timer.remainingSeconds == 0
                                    ? AppTheme.errorColor
                                    : null,
                              ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: timer.progress,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(timer.color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      timer.isRunning
                          ? Icons.pause_circle_filled
                          : (timer.isPaused
                              ? Icons.play_circle_filled
                              : Icons.play_circle_filled),
                      size: 40,
                      color: timer.color,
                    ),
                    onPressed: () {
                      final provider = context.read<TimerProvider>();
                      if (timer.isRunning) {
                        provider.pauseTimer(timer.id);
                      } else if (timer.isPaused) {
                        provider.resumeTimer(timer.id);
                      } else {
                        provider.startTimer(timer.id);
                      }
                    },
                  ),
                  if (!compact)
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                      onPressed: () {
                        context.read<TimerProvider>().resetTimer(timer.id);
                      },
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
