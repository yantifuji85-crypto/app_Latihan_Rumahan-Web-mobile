import 'dart:async';
import 'package:latihan_rumahan/data/workout_session.dart';

class WorkoutHistoryService {
  static final List<WorkoutSession> _data = [];

  static late final StreamController<List<WorkoutSession>> _ctl =
  StreamController<List<WorkoutSession>>.broadcast(
    onListen: () => _emit(),
  );

  static void _emit() {
    if (_ctl.isClosed) return;
    _ctl.add(List.unmodifiable(_data));
  }

  static Stream<List<WorkoutSession>> watchSessions() => _ctl.stream;

  static Future<void> addSession({
    required int minutes,
    required int calories,
    required int score,
  }) async {
    _data.add(
      WorkoutSession(
        at: DateTime.now(),
        minutes: minutes,
        calories: calories,
        score: score,
      ),
    );

    _data.sort((a, b) => a.at.compareTo(b.at));
    _emit();
  }

  // ✅ DEMO sekarang OFF by default (panggil manual kalau kamu mau demo)
  static void seedDemoIfEmpty() {
    if (_data.isNotEmpty) {
      _emit();
      return;
    }

    final now = DateTime.now();
    for (int i = 13; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final base = 10 + (13 - i);
      _data.add(
        WorkoutSession(
          at: DateTime(d.year, d.month, d.day, 10),
          minutes: base,
          calories: base * 6,
          score: base * 20,
        ),
      );
    }
    _emit();
  }

  // optional
  static void clearAll() {
    _data.clear();
    _emit();
  }

  static void dispose() {
    _ctl.close();
  }
}
