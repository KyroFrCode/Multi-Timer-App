import 'dart:async';
import 'package:flutter/material.dart';
import '../models/stopwatch_model.dart';

class StopwatchDisplay extends StatefulWidget {
  final StopwatchModel stopwatch;

  const StopwatchDisplay({
    super.key,
    required this.stopwatch,
  });

  @override
  State<StopwatchDisplay> createState() => _StopwatchDisplayState();
}

class _StopwatchDisplayState extends State<StopwatchDisplay> {
  Timer? _uiTimer;

  @override
  void initState() {
    super.initState();
    _startUiTimer();
  }

  void _startUiTimer() {
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (widget.stopwatch.isRunning) {
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(StopwatchDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stopwatch.isRunning != oldWidget.stopwatch.isRunning) {
      _startUiTimer();
    }
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.stopwatch.formattedTime,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
