import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

class HealthSyncService {
  HealthSyncService._();
  static final HealthSyncService I = HealthSyncService._();

  final Health _health = Health();
  bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    _configured = true;

    // penting untuk beberapa versi plugin
    _health.configure();

    if (kDebugMode) {
      debugPrint("HealthSyncService configured");
    }
  }

  HealthWorkoutActivityType _mapWorkoutType(String title) {
    final t = title.toLowerCase();

    if (t.contains("lari") || t.contains("run") || t.contains("jog")) {
      return HealthWorkoutActivityType.RUNNING;
    }

    // ✅ FIX: di package health namanya BIKING (bukan CYCLING)
    if (t.contains("sepeda") || t.contains("bike") || t.contains("cycling")) {
      return HealthWorkoutActivityType.BIKING;
    }

    if (t.contains("jalan") || t.contains("walk")) {
      return HealthWorkoutActivityType.WALKING;
    }

    if (t.contains("yoga")) return HealthWorkoutActivityType.YOGA;

    if (t.contains("stretch")) {
      return HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING;
    }

    if (t.contains("push") ||
        t.contains("pull") ||
        t.contains("squat") ||
        t.contains("strength")) {
      return HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING;
    }

    // default aman
    return HealthWorkoutActivityType.OTHER;
  }

  /// Request izin yang kita butuhkan (durasi, kalori, workout).
  Future<bool> requestAuth() async {
    await _ensureConfigured();

    final types = <HealthDataType>[
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.WORKOUT,
    ];

    final permissions = <HealthDataAccess>[
      HealthDataAccess.WRITE,
      HealthDataAccess.WRITE,
    ];

    try {
      // Android: kalau Health Connect belum ada, plugin bisa kasih status
      if (Platform.isAndroid) {
        await _health.getHealthConnectSdkStatus();
      }

      final ok = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );
      return ok;
    } catch (e) {
      if (kDebugMode) debugPrint("Health auth error: $e");
      return false;
    }
  }

  /// Kirim workout ke Health Connect / HealthKit
  Future<bool> writeWorkout({
    required String title,
    required DateTime start,
    required DateTime end,
    required int calories,
  }) async {
    await _ensureConfigured();

    try {
      final granted = await requestAuth();
      if (!granted) return false;

      final type = _mapWorkoutType(title);

      // ✅ FIX: totalEnergyBurned param = int? (bukan double)
      final okWorkout = await _health.writeWorkoutData(
        activityType: type,
        title: title,
        start: start,
        end: end,
        totalEnergyBurned: calories,
      );

      // Energi sebagai datapoint juga (lebih kompatibel)
      final okEnergy = await _health.writeHealthData(
        value: calories.toDouble(),
        type: HealthDataType.ACTIVE_ENERGY_BURNED,
        startTime: start,
        endTime: end,
      );

      return okWorkout && okEnergy;
    } catch (e) {
      if (kDebugMode) debugPrint("Health write error: $e");
      return false;
    }
  }
}
