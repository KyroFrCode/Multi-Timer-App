import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;
  bool _keepScreenOn = false;
  StorageService _storageService = StorageService();

  ThemeMode get themeMode => _themeMode;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get keepScreenOn => _keepScreenOn;

  ThemeData get lightTheme => AppTheme.lightTheme;
  ThemeData get darkTheme => AppTheme.darkTheme;

  Future<void> init() async {
    await _storageService.init();
    _themeMode =
        await _storageService.loadTheme() ? ThemeMode.dark : ThemeMode.system;
    _vibrationEnabled = await _storageService.loadVibration();
    _soundEnabled = await _storageService.loadSound();
    _notificationsEnabled = await _storageService.loadNotifications();
    _keepScreenOn = await _storageService.loadKeepScreenOn();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storageService.saveTheme(mode == ThemeMode.dark);
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    await _storageService.saveTheme(value);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    await _storageService.saveVibration(value);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _storageService.saveSound(value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _storageService.saveNotifications(value);
    notifyListeners();
  }

  Future<void> setKeepScreenOn(bool value) async {
    _keepScreenOn = value;
    await _storageService.saveKeepScreenOn(value);
    notifyListeners();
  }
}
