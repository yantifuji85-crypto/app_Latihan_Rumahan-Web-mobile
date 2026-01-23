import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models/weekly_plan.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      throw StateError("User belum login (FirebaseAuth.currentUser null)");
    }
    return u.uid;
  }

  // =========================
  // WEEKLY PLAN (SUDAH ADA)
  // =========================
  DocumentReference<Map<String, dynamic>> _weeklyPlanRef() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('weekly_plan')
        .doc('current');
  }

  Future<void> ensureDefaultWeeklyPlan() async {
    final ref = _weeklyPlanRef();
    final snap = await ref.get();

    if (snap.exists) return;

    final defaultDays = <Map<String, dynamic>>[
      {"day": 1, "title": "Full Body", "level": "Beginner", "steps": []},
      {"day": 2, "title": "Core", "level": "Beginner", "steps": []},
      {"day": 3, "title": "Lower Body", "level": "Beginner", "steps": []},
      {"day": 4, "title": "Upper Body", "level": "Beginner", "steps": []},
      {"day": 5, "title": "Cardio", "level": "Beginner", "steps": []},
      {"day": 6, "title": "Mobility", "level": "Beginner", "steps": []},
      {"day": 7, "title": "Rest", "level": "Beginner", "steps": []},
    ];

    await ref.set({
      "days": defaultDays,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Stream<List<WeeklyDayPlan>> watchWeeklyPlan() {
    final ref = _weeklyPlanRef();

    return ref.snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return <WeeklyDayPlan>[];

      final raw = (data["days"] as List?) ?? [];

      return raw
          .whereType<Map<String, dynamic>>()
          .map((m) => WeeklyDayPlan.fromMap(m))
          .toList();
    });
  }

  // =========================
  // ✅ WORKOUT HISTORY (BARU)
  // =========================
  CollectionReference<Map<String, dynamic>> _workoutHistoryCol() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('workout_history');
  }

  /// ✅ simpan 1 sesi workout ke Firestore (buat Laporan/Statistik beneran)
  Future<void> addWorkoutHistory({
    required String title,
    required String category, // latihan/program/tantangan
    required int minutes,
    required int calories,
    DateTime? start,
    DateTime? end,
  }) async {
    final now = DateTime.now();
    final endAt = end ?? now;
    final startAt = start ?? endAt.subtract(Duration(minutes: minutes));

    await _workoutHistoryCol().add({
      "title": title,
      "category": category,
      "minutes": minutes,
      "calories": calories,
      "startAt": Timestamp.fromDate(startAt),
      "endAt": Timestamp.fromDate(endAt),
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// (opsional) stream realtime workout history
  Stream<List<Map<String, dynamic>>> watchWorkoutHistory({int limit = 50}) {
    return _workoutHistoryCol()
        .orderBy("endAt", descending: true)
        .limit(limit)
        .snapshots()
        .map((q) => q.docs.map((d) => d.data()).toList());
  }
}
