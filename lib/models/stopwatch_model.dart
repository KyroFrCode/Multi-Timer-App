class StopwatchModel {
  final String id;
  String name;
  int elapsedMs;
  bool isRunning;
  String? groupId;

  StopwatchModel({
    required this.id,
    required this.name,
    this.elapsedMs = 0,
    this.isRunning = false,
    this.groupId,
  });

  String get formattedTime {
    final hours = elapsedMs ~/ 3600000;
    final minutes = (elapsedMs % 3600000) ~/ 60000;
    final seconds = (elapsedMs % 60000) ~/ 1000;
    final centiseconds = (elapsedMs % 1000) ~/ 10;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${centiseconds.toString().padLeft(2, '0')}';
  }

  StopwatchModel copyWith({
    String? id,
    String? name,
    int? elapsedMs,
    bool? isRunning,
    String? groupId,
  }) {
    return StopwatchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      isRunning: isRunning ?? this.isRunning,
      groupId: groupId ?? this.groupId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'elapsedMs': elapsedMs,
      'isRunning': isRunning,
      'groupId': groupId,
    };
  }

  factory StopwatchModel.fromJson(Map<String, dynamic> json) {
    return StopwatchModel(
      id: json['id'] as String,
      name: json['name'] as String,
      elapsedMs: json['elapsedMs'] as int? ?? 0,
      isRunning: json['isRunning'] as bool? ?? false,
      groupId: json['groupId'] as String?,
    );
  }
}

class StopwatchGroup {
  final String id;
  String name;
  List<String> stopwatchIds;

  StopwatchGroup({
    required this.id,
    required this.name,
    List<String>? stopwatchIds,
  }) : stopwatchIds = stopwatchIds ?? [];

  int get count => stopwatchIds.length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stopwatchIds': stopwatchIds,
    };
  }

  factory StopwatchGroup.fromJson(Map<String, dynamic> json) {
    return StopwatchGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      stopwatchIds: List<String>.from(json['stopwatchIds'] as List? ?? []),
    );
  }
}
