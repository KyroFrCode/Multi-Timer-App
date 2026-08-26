enum AlarmSound {
  bell('Bell', 'bell'),
  beep('Beep', 'beep'),
  chime('Chime', 'chime'),
  alarm('Alarm', 'alarm'),
  whistle('Whistle', 'whistle');

  final String displayName;
  final String fileName;
  
  const AlarmSound(this.displayName, this.fileName);
}
