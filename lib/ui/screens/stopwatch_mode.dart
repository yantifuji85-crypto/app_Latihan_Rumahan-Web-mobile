import 'dart:async';
import 'package:flutter/material.dart';
import '../../main.dart';

// ✅ supaya statistik ikut ke-update
import 'package:latihan_rumahan/data/services/workout_history_service.dart';

// ✅ TTS
import 'package:latihan_rumahan/data/services/tts_service.dart';

// ✅ Health sync
import 'package:latihan_rumahan/data/services/health_sync_service.dart';

// ✅ RTDB (DATABASE)
import 'package:latihan_rumahan/data/services/rtdb_service.dart';

class StopwatchModeScreen extends StatefulWidget {
  final String title;

  const StopwatchModeScreen({
    super.key,
    required this.title,
  });

  @override
  State<StopwatchModeScreen> createState() => _StopwatchModeScreenState();
}

class _StopwatchModeScreenState extends State<StopwatchModeScreen> {
  Timer? _ticker;
  bool _running = false;

  // ✅ stopwatch biar gak drift
  final Stopwatch _sw = Stopwatch();

  int _elapsedSeconds = 0;

  // buat health: catat start time saat beneran mulai
  DateTime? _startedAt;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    if (_running) return;

    _startedAt ??= DateTime.now();

    if (!_sw.isRunning) _sw.start();

    // ✅ suara mulai (optional)
    if (appState.tts) {
      await TtsService.I.speak("Mulai jogging.", flush: true);
    }

    setState(() => _running = true);

    _ticker ??= Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;

      final s = _sw.elapsed.inSeconds;
      if (s == _elapsedSeconds) return;

      setState(() => _elapsedSeconds = s);
    });
  }

  void _pause() {
    _ticker?.cancel();
    _ticker = null;

    _sw.stop();
    setState(() => _running = false);
  }

  void _reset() {
    _ticker?.cancel();
    _ticker = null;

    _sw
      ..stop()
      ..reset();

    setState(() {
      _running = false;
      _elapsedSeconds = 0;
      _startedAt = null;
    });
  }

  Future<void> _finish() async {
    // ✅ stop ticker dulu biar gak update lagi
    _ticker?.cancel();
    _ticker = null;

    // stop stopwatch
    _sw.stop();

    final end = DateTime.now();
    final start = _startedAt ?? end;

    // ✅ hitung menit (jogging biasanya dibulatkan ke menit terdekat)
    final minutes = (_elapsedSeconds / 60).round().clamp(0, 9999);

    setState(() => _running = false);

    // ✅ masuk history + laporan (AppState)
    appState.addWorkout(
      id: widget.title,
      nameId: widget.title,
      nameEn: widget.title,
      minutes: minutes,
    );

    // ✅ samain KKal dengan Laporan (8 kkal per menit)
    final int calories = minutes * 8;

    // ✅ masuk statistik (StatsScreen)
    await WorkoutHistoryService.addSession(
      minutes: minutes,
      calories: calories,
      score: minutes * 20,
    );

    // ✅ DATABASE: simpan ke Realtime Database (kalau user udah login)
    try {
      await RtdbService.I.addSession(
        title: widget.title,
        category: "jogging",
        minutes: minutes,
        calories: calories,
        start: start,
        end: end,
      );
    } catch (e) {
      // ignore: avoid_print
      print("RTDB save failed: $e");
    }

    // ✅ Kirim ke Health Connect / HealthKit kalau user aktifin
    if (appState.healthConnect) {
      try {
        await HealthSyncService.I.writeWorkout(
          title: widget.title,
          start: start,
          end: end,
          calories: calories,
        );
      } catch (e) {
        // ignore: avoid_print
        print("Health write failed: $e");
      }
    }

    // ✅ suara selesai
    if (appState.tts) {
      await TtsService.I.speak("Selesai. Bagus!", flush: true);
    }

    // reset stopwatch internal (biar kalau user ulangi dari dialog enak)
    _sw.reset();

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Selesai! 🎉", style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text(
          "Jogging '${widget.title}' selama ${_fmt(_elapsedSeconds)} sudah dicatat ke Laporan.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reset();
            },
            child: const Text("Ulangi"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Kembali"),
          ),
        ],
      ),
    );
  }

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // progress “loop” biar tetep ada bar, tapi gak butuh target
    final progress = ((_elapsedSeconds % 60) / 60).clamp(0.0, 1.0);

    final canFinish = _elapsedSeconds > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Timer Mode", style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Mode • Stopwatch (naik)",
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: cs.surfaceContainerHighest,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _fmt(_elapsedSeconds),
                        style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 18),

                      // ✅ tombol utama sama kayak timer
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _reset,
                              child: const Text("RESET", style: TextStyle(fontWeight: FontWeight.w900)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _running ? _pause : _start,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0B66FF),
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: Text(
                                  _running ? "PAUSE" : "START",
                                  style: const TextStyle(fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ✅ tombol SELESAI beneran (bukan debug)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: (!canFinish) ? null : _finish,
                          child: Text(
                            "SELESAI",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: (!canFinish)
                                  ? cs.onSurfaceVariant.withOpacity(0.5)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
