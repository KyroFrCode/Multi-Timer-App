import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timer_model.dart';
import '../models/timer_group.dart';
import '../models/tabata_preset.dart';
import '../models/stopwatch_model.dart';

class StorageService {
  static const String _timersKey = 'timers';
  static const String _groupsKey = 'groups';
  static const String _themeKey = 'isDarkMode';
  static const String _vibrationKey = 'vibrationEnabled';
  static const String _soundKey = 'soundEnabled';
  static const String _notificationsKey = 'notificationsEnabled';
  static const String _keepScreenOnKey = 'keepScreenOn';
  static const String _tabataPresetsKey = 'tabataPresets';
  static const String _stopwatchesKey = 'stopwatches';
  static const String _stopwatchGroupsKey = 'stopwatchGroups';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<TimerModel>> loadTimers() async {
    final String? data = _prefs.getString(_timersKey);
    if (data == null) return [];
    try {
      final List<dynamic> jsonList = json.decode(data);
      return jsonList.map((e) => TimerModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTimers(List<TimerModel> timers) async {
    final String data = json.encode(timers.map((e) => e.toJson()).toList());
    await _prefs.setString(_timersKey, data);
  }

  Future<List<TimerGroup>> loadGroups() async {
    final String? data = _prefs.getString(_groupsKey);
    if (data == null) return [];
    try {
      final List<dynamic> jsonList = json.decode(data);
      return jsonList.map((e) => TimerGroup.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveGroups(List<TimerGroup> groups) async {
    final String data = json.encode(groups.map((e) => e.toJson()).toList());
    await _prefs.setString(_groupsKey, data);
  }

  Future<bool> loadTheme() async {
    return _prefs.getBool(_themeKey) ?? false;
  }

  Future<void> saveTheme(bool isDarkMode) async {
    await _prefs.setBool(_themeKey, isDarkMode);
  }

  Future<bool> loadVibration() async {
    return _prefs.getBool(_vibrationKey) ?? true;
  }

  Future<void> saveVibration(bool value) async {
    await _prefs.setBool(_vibrationKey, value);
  }

  Future<bool> loadSound() async {
    return _prefs.getBool(_soundKey) ?? true;
  }

  Future<void> saveSound(bool value) async {
    await _prefs.setBool(_soundKey, value);
  }

  Future<bool> loadNotifications() async {
    return _prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> saveNotifications(bool value) async {
    await _prefs.setBool(_notificationsKey, value);
  }

  Future<bool> loadKeepScreenOn() async {
    return _prefs.getBool(_keepScreenOnKey) ?? false;
  }

  Future<void> saveKeepScreenOn(bool value) async {
    await _prefs.setBool(_keepScreenOnKey, value);
  }

  Future<List<TabataPreset>> loadTabataPresets() async {
    final String? data = _prefs.getString(_tabataPresetsKey);
    if (data == null) return _getDefaultPresets();
    try {
      final List<dynamic> jsonList = json.decode(data);
      return jsonList.map((e) => TabataPreset.fromJson(e)).toList();
    } catch (e) {
      return _getDefaultPresets();
    }
  }

  Future<void> saveTabataPresets(List<TabataPreset> presets) async {
    final String data = json.encode(presets.map((e) => e.toJson()).toList());
    await _prefs.setString(_tabataPresetsKey, data);
  }

  List<TabataPreset> _getDefaultPresets() {
    return [];
  }

  Future<List<StopwatchModel>> loadStopwatches() async {
    final String? data = _prefs.getString(_stopwatchesKey);
    if (data == null) return [];
    try {
      final List<dynamic> jsonList = json.decode(data);
      return jsonList.map((e) => StopwatchModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveStopwatches(List<StopwatchModel> list) async {
    final String data = json.encode(list.map((e) => e.toJson()).toList());
    await _prefs.setString(_stopwatchesKey, data);
  }

  Future<List<StopwatchGroup>> loadStopwatchGroups() async {
    final String? data = _prefs.getString(_stopwatchGroupsKey);
    if (data == null) return [];
    try {
      final List<dynamic> jsonList = json.decode(data);
      return jsonList.map((e) => StopwatchGroup.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveStopwatchGroups(List<StopwatchGroup> list) async {
    final String data = json.encode(list.map((e) => e.toJson()).toList());
    await _prefs.setString(_stopwatchGroupsKey, data);
  }
}
