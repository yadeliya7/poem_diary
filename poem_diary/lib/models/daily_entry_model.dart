class DailyEntry {
  final String moodCode;
  final String? note;
  final DateTime date;
  final List<String> mediaPaths;
  final Map<String, dynamic> activities;

  DailyEntry({
    required this.moodCode,
    this.note,
    required this.date,
    this.mediaPaths = const [],
    this.activities = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'moodCode': moodCode,
      'note': note,
      'date': date.toIso8601String(),
      'mediaPaths': mediaPaths,
      'activities': activities,
    };
  }

  factory DailyEntry.fromJson(Map<String, dynamic> json) {
    return DailyEntry(
      moodCode: json['moodCode'] as String,
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      mediaPaths:
          (json['mediaPaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      activities: (json['activities'] as Map<String, dynamic>?) ?? {},
    );
  }
}
