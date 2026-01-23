import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class RtdbService {
  RtdbService._();
  static final RtdbService I = RtdbService._();

  final FirebaseDatabase _db = FirebaseDatabase.instance;

  String get _uid {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) throw StateError("User belum login (FirebaseAuth.currentUser null)");
    return u.uid;
  }

  DatabaseReference _sessionsRef() => _db.ref("sessions").child(_uid);

  /// Simpan 1 sesi latihan ke Realtime Database:
  /// path: sessions/{uid}/{pushId}
  Future<void> addSession({
    required String title,
    required String category,
    required int minutes,
    required int calories,
    required DateTime start,
    required DateTime end,
  }) async {
    final ref = _sessionsRef().push();

    final data = <String, dynamic>{
      "title": title,
      "category": category,
      "minutes": minutes,
      "calories": calories,
      "startAt": start.toIso8601String(),
      "endAt": end.toIso8601String(),
      "createdAt": ServerValue.timestamp, // cocok sama rules + index
    };

    await ref.set(data);

    if (kDebugMode) {
      debugPrint("✅ RTDB saved: ${ref.key}");
    }
  }
}
