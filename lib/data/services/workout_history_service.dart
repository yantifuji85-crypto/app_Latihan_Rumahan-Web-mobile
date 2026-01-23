import 'dart:async';
import 'package:latihan_rumahan/data/workout_session.dart';

class WorkoutHistoryService {
  static final List<WorkoutSession> _data = [];

  // ✅ begitu ada listener baru, kirim data terakhir
  static late final StreamController<List<WorkoutSession>> _ctl =
  StreamController<List<WorkoutSession>>.broadcast(
    onListen: () {
      _emit();
    },
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

    // urutin lama -> baru
    _data.sort((a, b) => a.at.compareTo(b.at));

    _emit();
  }

  // ✅ jangan seed demo biar data akurat
  static void seedDemoIfEmpty() {
    _emit();
  }

  static void dispose() {
    _ctl.close();
  }
}
