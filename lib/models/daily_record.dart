/// 일일 섭취 기록 데이터 모델
class DailyRecord {
  final DateTime date;
  final List<String> analysisIds;
  final int totalCalories;
  final int goalCalories;

  DailyRecord({
    required this.date,
    required this.analysisIds,
    required this.totalCalories,
    this.goalCalories = 2000,
  });

  double get progress =>
      goalCalories > 0 ? (totalCalories / goalCalories).clamp(0.0, 2.0) : 0.0;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'analysisIds': analysisIds,
        'totalCalories': totalCalories,
        'goalCalories': goalCalories,
      };

  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord(
      date: DateTime.parse(json['date'] as String),
      analysisIds: (json['analysisIds'] as List).cast<String>(),
      totalCalories: json['totalCalories'] as int,
      goalCalories: json['goalCalories'] as int? ?? 2000,
    );
  }
}
