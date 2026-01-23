class WorkoutHistory {
  final String nameId; // nama Indo
  final String nameEn; // nama Inggris
  final int minutes;
  final DateTime at;

  const WorkoutHistory({
    required this.nameId,
    required this.nameEn,
    required this.minutes,
    required this.at,
  });

  String displayName(String language) {
    if (language == "English") return nameEn;
    return nameId;
  }
}
