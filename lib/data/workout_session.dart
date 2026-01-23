class WorkoutSession {
  final DateTime at;        // kapan latihan
  final int minutes;        // durasi
  final int calories;       // opsional, bisa kamu hitung sendiri
  final int score;          // opsional (mis. reps total / poin)

  WorkoutSession({
    required this.at,
    required this.minutes,
    required this.calories,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
    "at": at.toIso8601String(),
    "minutes": minutes,
    "calories": calories,
    "score": score,
  };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
    at: DateTime.parse(json["at"] as String),
    minutes: (json["minutes"] ?? 0) as int,
    calories: (json["calories"] ?? 0) as int,
    score: (json["score"] ?? 0) as int,
  );
}
