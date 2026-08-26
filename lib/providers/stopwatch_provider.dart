import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/stopwatch_model.dart';
import '../services/storage_service.dart';

class StopwatchProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final Uuid _uuid = const Uuid();
  Timer? _ticker;

  List<StopwatchModel> _stopwatches = [];
  List<StopwatchGroup> _groups = [];
  bool _isLoading = true;
  int _tickCount = 0;

  List<StopwatchModel> get stopwatches => _stopwatches;
  List<StopwatchGroup> get groups => _groups;
  bool get isLoading => _isLoading;
  bool get hasRunning => _stopwatches.any((s) => s.isRunning);

  int _runningCount = 0;
  int get runningCount => _runningCount;

  List<String> get activeTimerNames {
    return _stopwatches.where((s) => s.isRunning).map((s) => s.name).toList();
  }

  Future<void> init() async {
    await _storageService.init();
    _stopwatches = await _storageService.loadStopwatches();
    _groups = await _storageService.loadStopwatchGroups();
    _updateRunningCount();
    _isLoading = false;
    _startTicker();
    notifyListeners();
  }

  void _updateRunningCount() {
    _runningCount = 0;
    for (var sw in _stopwatches) {
      if (sw.isRunning) _runningCount++;
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      bool anyRunning = false;
      for (var sw in _stopwatches) {
        if (sw.isRunning) {
          sw.elapsedMs += 50;
          anyRunning = true;
        }
      }
      if (anyRunning) {
        _tickCount++;
        if (_tickCount % 2 == 0) {
          notifyListeners();
        }
      }
    });
  }

  Future<void> addStopwatch(String name) async {
    final sw = StopwatchModel(
      id: _uuid.v4(),
      name: name,
    );
    _stopwatches.add(sw);
    await _storageService.saveStopwatches(_stopwatches);
    notifyListeners();
  }

  Future<void> updateStopwatch(StopwatchModel sw) async {
    final index = _stopwatches.indexWhere((s) => s.id == sw.id);
    if (index != -1) {
      _stopwatches[index] = sw;
      await _storageService.saveStopwatches(_stopwatches);
      notifyListeners();
    }
  }

  Future<void> deleteStopwatch(String id) async {
    _stopwatches.removeWhere((s) => s.id == id);
    for (var group in _groups) {
      group.stopwatchIds.remove(id);
    }
    _updateRunningCount();
    await _storageService.saveStopwatches(_stopwatches);
    await _storageService.saveStopwatchGroups(_groups);
    notifyListeners();
  }

  void startStopwatch(String id) {
    final index = _stopwatches.indexWhere((s) => s.id == id);
    if (index != -1) {
      _stopwatches[index].isRunning = true;
      _updateRunningCount();
      notifyListeners();
    }
  }

  void stopStopwatch(String id) {
    final index = _stopwatches.indexWhere((s) => s.id == id);
    if (index != -1) {
      _stopwatches[index].isRunning = false;
      _updateRunningCount();
      notifyListeners();
    }
  }

  void resetStopwatch(String id) {
    final index = _stopwatches.indexWhere((s) => s.id == id);
    if (index != -1) {
      _stopwatches[index].isRunning = false;
      _stopwatches[index].elapsedMs = 0;
      _updateRunningCount();
      notifyListeners();
    }
  }

  Future<void> addGroup(String name) async {
    final group = StopwatchGroup(
      id: _uuid.v4(),
      name: name,
    );
    _groups.add(group);
    await _storageService.saveStopwatchGroups(_groups);
    notifyListeners();
  }

  Future<void> deleteGroup(String id) async {
    final group = _groups.firstWhere((g) => g.id == id);
    for (var swId in group.stopwatchIds) {
      final idx = _stopwatches.indexWhere((s) => s.id == swId);
      if (idx != -1) _stopwatches[idx].groupId = null;
    }
    _groups.removeWhere((g) => g.id == id);
    _updateRunningCount();
    await _storageService.saveStopwatches(_stopwatches);
    await _storageService.saveStopwatchGroups(_groups);
    notifyListeners();
  }

  Future<void> addStopwatchToGroup(String swId, String groupId) async {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex != -1 && !_groups[groupIndex].stopwatchIds.contains(swId)) {
      _groups[groupIndex].stopwatchIds.add(swId);
      final swIndex = _stopwatches.indexWhere((s) => s.id == swId);
      if (swIndex != -1) _stopwatches[swIndex].groupId = groupId;
      await _storageService.saveStopwatches(_stopwatches);
      await _storageService.saveStopwatchGroups(_groups);
      notifyListeners();
    }
  }

  Future<void> removeStopwatchFromGroup(String swId, String groupId) async {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex != -1) {
      _groups[groupIndex].stopwatchIds.remove(swId);
      final swIndex = _stopwatches.indexWhere((s) => s.id == swId);
      if (swIndex != -1) _stopwatches[swIndex].groupId = null;
      await _storageService.saveStopwatches(_stopwatches);
      await _storageService.saveStopwatchGroups(_groups);
      notifyListeners();
    }
  }

  void startGroup(String groupId) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    bool changed = false;
    for (var swId in group.stopwatchIds) {
      final index = _stopwatches.indexWhere((s) => s.id == swId);
      if (index != -1 && !_stopwatches[index].isRunning) {
        _stopwatches[index].isRunning = true;
        changed = true;
      }
    }
    if (changed) {
      _updateRunningCount();
      notifyListeners();
    }
  }

  void stopGroup(String groupId) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    bool changed = false;
    for (var swId in group.stopwatchIds) {
      final index = _stopwatches.indexWhere((s) => s.id == swId);
      if (index != -1 && _stopwatches[index].isRunning) {
        _stopwatches[index].isRunning = false;
        changed = true;
      }
    }
    if (changed) {
      _updateRunningCount();
      notifyListeners();
    }
  }

  void resetGroup(String groupId) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    bool changed = false;
    for (var swId in group.stopwatchIds) {
      final index = _stopwatches.indexWhere((s) => s.id == swId);
      if (index != -1) {
        _stopwatches[index].isRunning = false;
        _stopwatches[index].elapsedMs = 0;
        changed = true;
      }
    }
    if (changed) {
      _updateRunningCount();
      notifyListeners();
    }
  }

  List<StopwatchModel> getStopwatchesInGroup(String groupId) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    return _stopwatches
        .where((s) => group.stopwatchIds.contains(s.id))
        .toList();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
