import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/timer_model.dart';
import '../models/timer_group.dart';
import '../models/alarm_sound.dart';
import '../services/timer_service.dart';
import '../services/storage_service.dart';

class TimerProvider extends ChangeNotifier {
  final TimerService _timerService = TimerService();
  final StorageService _storageService = StorageService();
  final Uuid _uuid = const Uuid();

  List<TimerModel> _timers = [];
  List<TimerGroup> _groups = [];
  bool _isLoading = true;

  List<TimerModel> get timers => _timers;
  List<TimerGroup> get groups => _groups;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    await _storageService.init();
    _timers = await _storageService.loadTimers();
    _groups = await _storageService.loadGroups();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTimer({
    required String name,
    required int durationSeconds,
    required int colorValue,
    required AlarmSound alarmSound,
    bool vibrationEnabled = true,
  }) async {
    final timer = TimerModel(
      id: _uuid.v4(),
      name: name,
      durationSeconds: durationSeconds,
      color: Color(colorValue),
      alarmSound: alarmSound,
      vibrationEnabled: vibrationEnabled,
      remainingSeconds: durationSeconds,
    );
    _timers.add(timer);
    await _storageService.saveTimers(_timers);
    notifyListeners();
  }

  Future<void> updateTimer(TimerModel timer) async {
    final index = _timers.indexWhere((t) => t.id == timer.id);
    if (index != -1) {
      _timers[index] = timer;
      await _storageService.saveTimers(_timers);
      notifyListeners();
    }
  }

  Future<void> deleteTimer(String timerId) async {
    _timerService.stopTimer(timerId);
    _timers.removeWhere((t) => t.id == timerId);
    for (var group in _groups) {
      group.timerIds.remove(timerId);
    }
    await _storageService.saveTimers(_timers);
    await _storageService.saveGroups(_groups);
    notifyListeners();
  }

  void startTimer(String timerId) {
    final index = _timers.indexWhere((t) => t.id == timerId);
    if (index != -1) {
      _timers[index].isRunning = true;
      _timers[index].isPaused = false;
      _timers[index].startedAt = DateTime.now();

      _timerService.startTimer(
        _timers[index],
        onComplete: () => _onTimerComplete(timerId),
        onTickUpdate: () => notifyListeners(),
      );
      notifyListeners();
    }
  }

  void pauseTimer(String timerId) {
    final index = _timers.indexWhere((t) => t.id == timerId);
    if (index != -1) {
      _timers[index].isRunning = false;
      _timers[index].isPaused = true;
      _timers[index].pausedAt = DateTime.now();

      _timerService.pauseTimer(timerId);
      notifyListeners();
    }
  }

  void resumeTimer(String timerId) {
    final index = _timers.indexWhere((t) => t.id == timerId);
    if (index != -1) {
      _timers[index].isRunning = true;
      _timers[index].isPaused = false;

      _timerService.startTimer(
        _timers[index],
        onComplete: () => _onTimerComplete(timerId),
        onTickUpdate: () => notifyListeners(),
      );
      notifyListeners();
    }
  }

  void resetTimer(String timerId) {
    final index = _timers.indexWhere((t) => t.id == timerId);
    if (index != -1) {
      _timerService.stopTimer(timerId);
      _timers[index].remainingSeconds = _timers[index].durationSeconds;
      _timers[index].isRunning = false;
      _timers[index].isPaused = false;
      _timers[index].startedAt = null;
      _timers[index].pausedAt = null;
      notifyListeners();
    }
  }

  void _onTimerComplete(String timerId) {
    final index = _timers.indexWhere((t) => t.id == timerId);
    if (index != -1) {
      _timers[index].isRunning = false;
      _timers[index].isPaused = false;
      _timers[index].startedAt = null;
      _timers[index].pausedAt = null;
      notifyListeners();
    }
  }

  void stopAllTimers() {
    _timerService.stopAllTimers();
    for (var timer in _timers) {
      timer.isRunning = false;
      timer.isPaused = false;
    }
    notifyListeners();
  }

  void stopAlarm() {
    _timerService.stopAlarm();
  }

  Future<void> addGroup(String name) async {
    final group = TimerGroup(
      id: _uuid.v4(),
      name: name,
    );
    _groups.add(group);
    await _storageService.saveGroups(_groups);
    notifyListeners();
  }

  Future<void> updateGroup(TimerGroup group) async {
    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _groups[index] = group;
      await _storageService.saveGroups(_groups);
      notifyListeners();
    }
  }

  Future<void> deleteGroup(String groupId) async {
    final group = _groups.firstWhere((g) => g.id == groupId);
    for (var timerId in group.timerIds) {
      final timerIndex = _timers.indexWhere((t) => t.id == timerId);
      if (timerIndex != -1) {
        _timers[timerIndex].groupId = null;
      }
    }
    _groups.removeWhere((g) => g.id == groupId);
    await _storageService.saveTimers(_timers);
    await _storageService.saveGroups(_groups);
    notifyListeners();
  }

  Future<void> addTimerToGroup(String timerId, String groupId) async {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex != -1 && !_groups[groupIndex].timerIds.contains(timerId)) {
      _groups[groupIndex].timerIds.add(timerId);

      final timerIndex = _timers.indexWhere((t) => t.id == timerId);
      if (timerIndex != -1) {
        _timers[timerIndex].groupId = groupId;
      }

      await _storageService.saveTimers(_timers);
      await _storageService.saveGroups(_groups);
      notifyListeners();
    }
  }

  Future<void> removeTimerFromGroup(String timerId, String groupId) async {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex != -1) {
      _groups[groupIndex].timerIds.remove(timerId);

      final timerIndex = _timers.indexWhere((t) => t.id == timerId);
      if (timerIndex != -1) {
        _timers[timerIndex].groupId = null;
      }

      await _storageService.saveTimers(_timers);
      await _storageService.saveGroups(_groups);
      notifyListeners();
    }
  }

  void toggleGroupExpanded(String groupId) {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      _groups[index].isExpanded = !_groups[index].isExpanded;
      notifyListeners();
    }
  }

  void startGroup(String groupId) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    for (var timerId in group.timerIds) {
      startTimer(timerId);
    }
  }

  void pauseGroup(String groupId) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    for (var timerId in group.timerIds) {
      pauseTimer(timerId);
    }
  }

  void resetGroup(String groupId) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    for (var timerId in group.timerIds) {
      resetTimer(timerId);
    }
  }

  List<TimerModel> getTimersInGroup(String groupId) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    return _timers.where((t) => group.timerIds.contains(t.id)).toList();
  }

  List<TimerModel> get availableTimers {
    return _timers.where((t) => t.groupId == null).toList();
  }

  @override
  void dispose() {
    _timerService.dispose();
    super.dispose();
  }
}
