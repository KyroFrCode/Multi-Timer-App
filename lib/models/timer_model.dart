import 'package:flutter/material.dart';
import 'alarm_sound.dart';

class TimerModel {
  final String id;
  String name;
  int durationSeconds;
  int remainingSeconds;
  Color color;
  AlarmSound alarmSound;
  bool vibrationEnabled;
  String? customSoundPath;
  bool isRunning;
  bool isPaused;
  String? groupId;
  DateTime? startedAt;
  DateTime? pausedAt;

  TimerModel({
    required this.id,
    required this.name,
    required this.durationSeconds,
    required this.color,
    this.alarmSound = AlarmSound.bell,
    this.vibrationEnabled = true,
    this.customSoundPath,
    this.isRunning = false,
    this.isPaused = false,
    this.groupId,
    this.startedAt,
    this.pausedAt,
    int? remainingSeconds,
  }) : remainingSeconds = remainingSeconds ?? durationSeconds;

  double get progress {
    if (durationSeconds == 0) return 0;
    return (durationSeconds - remainingSeconds) / durationSeconds;
  }

  String get formattedTime {
    final hours = remainingSeconds ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;
    final seconds = remainingSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  TimerModel copyWith({
    String? id,
    String? name,
    int? durationSeconds,
    int? remainingSeconds,
    Color? color,
    AlarmSound? alarmSound,
    bool? vibrationEnabled,
    String? customSoundPath,
    bool? isRunning,
    bool? isPaused,
    String? groupId,
    DateTime? startedAt,
    DateTime? pausedAt,
  }) {
    return TimerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      color: color ?? this.color,
      alarmSound: alarmSound ?? this.alarmSound,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      customSoundPath: customSoundPath ?? this.customSoundPath,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      groupId: groupId ?? this.groupId,
      startedAt: startedAt ?? this.startedAt,
      pausedAt: pausedAt ?? this.pausedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'durationSeconds': durationSeconds,
      'remainingSeconds': remainingSeconds,
      'colorValue': color.toARGB32(),
      'alarmSound': alarmSound.name,
      'vibrationEnabled': vibrationEnabled,
      'customSoundPath': customSoundPath,
      'isRunning': isRunning,
      'isPaused': isPaused,
      'groupId': groupId,
      'startedAt': startedAt?.toIso8601String(),
      'pausedAt': pausedAt?.toIso8601String(),
    };
  }

  factory TimerModel.fromJson(Map<String, dynamic> json) {
    return TimerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      durationSeconds: json['durationSeconds'] as int,
      remainingSeconds: json['remainingSeconds'] as int,
      color: Color(json['colorValue'] as int),
      alarmSound: AlarmSound.values.firstWhere(
        (e) => e.name == json['alarmSound'],
        orElse: () => AlarmSound.bell,
      ),
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      customSoundPath: json['customSoundPath'] as String?,
      isRunning: json['isRunning'] as bool? ?? false,
      isPaused: json['isPaused'] as bool? ?? false,
      groupId: json['groupId'] as String?,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      pausedAt: json['pausedAt'] != null
          ? DateTime.parse(json['pausedAt'] as String)
          : null,
    );
  }

  String toShareString() {
    return 'TIMER|$name|$durationSeconds|${color.toARGB32()}|${alarmSound.name}|$vibrationEnabled';
  }

  static TimerModel? fromShareString(String data) {
    try {
      final parts = data.split('|');
      if (parts[0] != 'TIMER' || parts.length < 6) return null;
      return TimerModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: parts[1],
        durationSeconds: int.parse(parts[2]),
        color: Color(int.parse(parts[3])),
        alarmSound: AlarmSound.values.firstWhere(
          (e) => e.name == parts[4],
          orElse: () => AlarmSound.bell,
        ),
        vibrationEnabled: parts[5] == 'true',
      );
    } catch (e) {
      return null;
    }
  }
}
