import 'package:flutter/foundation.dart';

/// =======================
/// WORKOUT LOG (UI / LOCAL)
/// =======================
class WorkoutLog {
  final DateTime time;

  final String id;
  final String nameId;
  final String nameEn;

  final int minutes;

  const WorkoutLog({
    required this.time,
    required this.id,
    required this.nameId,
    required this.nameEn,
    required this.minutes,
  });

  String displayName(String language) {
    return (language == "English") ? nameEn : nameId;
  }
}

/// =======================
/// WEIGHT LOG (UI / LOCAL)
/// =======================
class WeightLog {
  final DateTime time;
  final double kg;

  const WeightLog({
    required this.time,
    required this.kg,
  });
}

/// =======================
/// APP STATE
/// =======================
class AppState extends ChangeNotifier {
  bool darkMode = false;
  String language = "Default"; // Default | Indonesia | English
  bool tts = false;

  // ✅ toggle health sync
  bool healthConnect = false;

  // ✅ toggle notifikasi
  bool notifications = false;

  // ✅ weekly target (goal) disimpan di state
  int weeklyGoal = 4;

  // ✅ avatar url disimpan di state
  String avatarUrl =
      "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80";

  // =======================
  // ✅ WORKOUT SETTINGS (GLOBAL)
  // =======================
  String workoutGoal = "Fat Loss"; // Fat Loss | Muscle Gain | Cardio | Maintain
  String workoutLevel = "Pemula"; // Pemula | Menengah | Lanjutan
  int workoutRestSec = 30; // 10..120
  bool workoutAutoNext = true;

  final List<WorkoutLog> history = [];
  final List<WeightLog> weights = [];

  int get totalWorkout => history.length;
  int get totalMinutes => history.fold<int>(0, (sum, e) => sum + e.minutes);

  // estimasi kcal kasar
  int get totalKcal => totalMinutes * 8;

  // =======================
  // SETTINGS
  // =======================
  void setDarkMode(bool v) {
    darkMode = v;
    notifyListeners();
  }

  void setLanguage(String v) {
    language = v;
    notifyListeners();
  }

  void setTts(bool v) {
    tts = v;
    notifyListeners();
  }

  void setHealthConnect(bool v) {
    healthConnect = v;
    notifyListeners();
  }

  void setNotifications(bool v) {
    notifications = v;
    notifyListeners();
  }

  // ✅ set weekly goal
  void setWeeklyGoal(int v) {
    weeklyGoal = v.clamp(1, 99);
    notifyListeners();
  }

  // ✅ set avatar
  void setAvatarUrl(String url) {
    avatarUrl = url;
    notifyListeners();
  }

  // ✅ set workout settings
  void setWorkoutSettings({
    String? goal,
    String? level,
    int? restSec,
    bool? autoNext,
  }) {
    if (goal != null) workoutGoal = goal;
    if (level != null) workoutLevel = level;
    if (restSec != null) workoutRestSec = restSec.clamp(10, 120);
    if (autoNext != null) workoutAutoNext = autoNext;
    notifyListeners();
  }

  // =======================
  // WORKOUT HISTORY
  // =======================
  void addWorkout({
    required String id,
    required String nameId,
    required String nameEn,
    required int minutes,
  }) {
    history.insert(
      0,
      WorkoutLog(
        time: DateTime.now(),
        id: id,
        nameId: nameId,
        nameEn: nameEn,
        minutes: minutes,
      ),
    );
    notifyListeners();
  }

  // =======================
  // WEEKLY COUNT (buat Target Mingguan)
  // =======================
  DateTime _startOfWeek(DateTime d) {
    // Monday = 1 ... Sunday = 7
    final start =
    DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));
    return start;
  }

  int get weeklyDoneCount {
    final now = DateTime.now();
    final start = _startOfWeek(now);
    final end = start.add(const Duration(days: 7));

    // ✅ FIX: start inclusive biar gak miss
    return history.where((e) {
      final t = e.time;
      final afterOrSameStart = !t.isBefore(start); // >= start
      final beforeEnd = t.isBefore(end); // < end
      return afterOrSameStart && beforeEnd;
    }).length;
  }

  // =======================
  // WEIGHT
  // =======================
  void addWeight(double kg) {
    final v = double.parse(kg.toStringAsFixed(1));
    weights.add(WeightLog(time: DateTime.now(), kg: v));
    weights.sort((a, b) => a.time.compareTo(b.time));
    notifyListeners();
  }

  double? get latestWeight => weights.isEmpty ? null : weights.last.kg;
}
