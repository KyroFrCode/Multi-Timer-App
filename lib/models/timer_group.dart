class TimerGroup {
  final String id;
  String name;
  List<String> timerIds;
  bool isExpanded;

  TimerGroup({
    required this.id,
    required this.name,
    List<String>? timerIds,
    this.isExpanded = false,
  }) : timerIds = timerIds ?? [];

  int get timerCount => timerIds.length;

  TimerGroup copyWith({
    String? id,
    String? name,
    List<String>? timerIds,
    bool? isExpanded,
  }) {
    return TimerGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      timerIds: timerIds ?? List.from(this.timerIds),
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'timerIds': timerIds,
      'isExpanded': isExpanded,
    };
  }

  factory TimerGroup.fromJson(Map<String, dynamic> json) {
    return TimerGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      timerIds: List<String>.from(json['timerIds'] as List? ?? []),
      isExpanded: json['isExpanded'] as bool? ?? false,
    );
  }
}
