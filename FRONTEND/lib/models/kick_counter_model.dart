// lib/models/kick_counter.dart
class KickCounter {
  final int? id;
  final int kickCount;
  final DateTime recordedAt;
  final int? duration;

  KickCounter({
    this.id,
    required this.kickCount,
    required this.recordedAt,
    this.duration,
  });

  factory KickCounter.fromJson(Map<String, dynamic> json) {
    return KickCounter(
      id: json['id'],
      kickCount: json['kick_count'],
      recordedAt: DateTime.parse(json['recorded_at']), 
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kick_count': kickCount,
      'recorded_at': recordedAt.toIso8601String(),
      'duration': duration,
    };
  }
}