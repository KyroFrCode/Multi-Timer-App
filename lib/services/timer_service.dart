import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../models/timer_model.dart';
import '../models/alarm_sound.dart';

class TimerService {
  final Map<String, Timer> _timers = {};
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<String, VoidCallback> _onTimerComplete = {};
  final Map<String, VoidCallback> _onTick = {};
  
  void startTimer(TimerModel timer, {VoidCallback? onComplete, VoidCallback? onTickUpdate}) {
    stopTimer(timer.id);
    
    _onTimerComplete[timer.id] = onComplete ?? () {};
    _onTick[timer.id] = onTickUpdate ?? () {};
    
    _timers[timer.id] = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timer.remainingSeconds > 0) {
        timer.remainingSeconds--;
        _onTick[timer.id]?.call();
      }
      
      if (timer.remainingSeconds <= 0) {
        stopTimer(timer.id);
        _playAlarm(timer.alarmSound);
        _onTimerComplete[timer.id]?.call();
      }
    });
  }

  void pauseTimer(String timerId) {
    _timers[timerId]?.cancel();
    _timers.remove(timerId);
  }

  void stopTimer(String timerId) {
    _timers[timerId]?.cancel();
    _timers.remove(timerId);
    _onTimerComplete.remove(timerId);
    _onTick.remove(timerId);
  }

  void stopAllTimers() {
    for (var timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _onTimerComplete.clear();
    _onTick.clear();
  }

  bool isTimerRunning(String timerId) {
    return _timers.containsKey(timerId);
  }

  Future<void> _playAlarm(AlarmSound sound) async {
    try {
      await _audioPlayer.play(AssetSource('sounds/${sound.fileName}.mp3'));
    } catch (e) {
      HapticFeedback.vibrate();
    }
  }

  void stopAlarm() {
    _audioPlayer.stop();
  }

  void dispose() {
    stopAllTimers();
    _audioPlayer.dispose();
  }
}
