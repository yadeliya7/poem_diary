class DailyEntry {
  final String moodCode;
  final String? note;
  final DateTime date;

  DailyEntry({required this.moodCode, this.note, required this.date});

  Map<String, dynamic> toJson() {
    return {'moodCode': moodCode, 'note': note, 'date': date.toIso8601String()};
  }

  factory DailyEntry.fromJson(Map<String, dynamic> json) {
    return DailyEntry(
      moodCode: json['moodCode'] as String,
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
