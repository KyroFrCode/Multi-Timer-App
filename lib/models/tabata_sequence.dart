import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'tabata_preset.dart';

class TabataStep {
  final String id;
  final String name;
  final int durationSeconds;
  final bool isRest;

  TabataStep({
    required this.id,
    required this.name,
    required this.durationSeconds,
    required this.isRest,
  });

  TabataStep copyWith({
    String? id,
    String? name,
    int? durationSeconds,
    bool? isRest,
  }) {
    return TabataStep(
      id: id ?? this.id,
      name: name ?? this.name,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isRest: isRest ?? this.isRest,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'durationSeconds': durationSeconds,
      'isRest': isRest,
    };
  }

  factory TabataStep.fromJson(Map<String, dynamic> json) {
    return TabataStep(
      id: json['id'] as String,
      name: json['name'] as String,
      durationSeconds: json['durationSeconds'] as int,
      isRest: json['isRest'] as bool,
    );
  }
}

class TabataSequence {
  final String id;
  final String name;
  final List<TabataStep> steps;
  final Color color;

  TabataSequence({
    required this.id,
    required this.name,
    required this.steps,
    this.color = const Color(0xFF6750A4),
  });

  int get totalSeconds => steps.fold(0, (sum, s) => sum + s.durationSeconds);

  String get totalDuration {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'steps': steps.map((s) => s.toJson()).toList(),
      'colorValue': color.toARGB32(),
    };
  }

  factory TabataSequence.fromJson(Map<String, dynamic> json) {
    return TabataSequence(
      id: json['id'] as String,
      name: json['name'] as String,
      steps:
          (json['steps'] as List).map((s) => TabataStep.fromJson(s)).toList(),
      color: Color(json['colorValue'] as int? ?? 0xFF6750A4),
    );
  }

  factory TabataSequence.fromPreset(TabataPreset preset) {
    final steps = <TabataStep>[];
    for (int i = 0; i < preset.rounds; i++) {
      steps.add(TabataStep(
        id: const Uuid().v4(),
        name: 'Work ${i + 1}',
        durationSeconds: preset.workSeconds,
        isRest: false,
      ));
      if (preset.restSeconds > 0) {
        steps.add(TabataStep(
          id: const Uuid().v4(),
          name: 'Rest ${i + 1}',
          durationSeconds: preset.restSeconds,
          isRest: true,
        ));
      }
    }
    return TabataSequence(
      id: preset.id,
      name: preset.name,
      steps: steps,
      color: const Color(0xFF6750A4),
    );
  }

  TabataPreset toPreset() {
    final workSteps = steps.where((s) => !s.isRest).toList();
    final restSteps = steps.where((s) => s.isRest).toList();
    return TabataPreset(
      id: id,
      name: name,
      workSeconds: workSteps.isNotEmpty ? workSteps.first.durationSeconds : 20,
      restSeconds: restSteps.isNotEmpty ? restSteps.first.durationSeconds : 10,
      rounds: workSteps.length,
      category: TabataCategory.workout,
    );
  }

  String toShareString() {
    final stepsStr = steps
        .map((s) => '${s.name}:${s.durationSeconds}:${s.isRest ? 1 : 0}')
        .join(',');
    return 'TABATA_SEQ|$name|$stepsStr';
  }

  static TabataSequence? fromShareString(String data) {
    try {
      final parts = data.split('|');
      if (parts[0] != 'TABATA_SEQ' || parts.length < 3) return null;
      final name = parts[1];
      final stepsStr = parts[2].split(',');
      final steps = <TabataStep>[];
      for (final step in stepsStr) {
        final stepParts = step.split(':');
        if (stepParts.length != 3) continue;
        steps.add(TabataStep(
          id: const Uuid().v4(),
          name: stepParts[0],
          durationSeconds: int.parse(stepParts[1]),
          isRest: stepParts[2] == '1',
        ));
      }
      if (steps.isEmpty) return null;
      return TabataSequence(
        id: const Uuid().v4(),
        name: name,
        steps: steps,
      );
    } catch (e) {
      return null;
    }
  }
}
