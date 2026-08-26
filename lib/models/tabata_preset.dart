enum TabataCategory {
  workout('Workout'),
  cooking('Cooking');

  final String displayName;
  const TabataCategory(this.displayName);
}

class TabataPreset {
  final String id;
  final String name;
  final int workSeconds;
  final int restSeconds;
  final int rounds;
  final TabataCategory category;

  TabataPreset({
    required this.id,
    required this.name,
    required this.workSeconds,
    required this.restSeconds,
    required this.rounds,
    required this.category,
  });

  int get totalSeconds => (workSeconds + restSeconds) * rounds;

  String get formattedDuration {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'workSeconds': workSeconds,
      'restSeconds': restSeconds,
      'rounds': rounds,
      'category': category.name,
    };
  }

  factory TabataPreset.fromJson(Map<String, dynamic> json) {
    return TabataPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      workSeconds: json['workSeconds'] as int,
      restSeconds: json['restSeconds'] as int,
      rounds: json['rounds'] as int,
      category: TabataCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TabataCategory.workout,
      ),
    );
  }

  String toShareString() {
    return 'TABATA|$name|$workSeconds|$restSeconds|$rounds|${category.name}';
  }

  static TabataPreset? fromShareString(String data) {
    try {
      final parts = data.split('|');
      if (parts[0] == 'TABATA' && parts.length == 6) {
        return TabataPreset(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: parts[1],
          workSeconds: int.parse(parts[2]),
          restSeconds: int.parse(parts[3]),
          rounds: int.parse(parts[4]),
          category: TabataCategory.values.firstWhere(
            (e) => e.name == parts[5],
            orElse: () => TabataCategory.workout,
          ),
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
