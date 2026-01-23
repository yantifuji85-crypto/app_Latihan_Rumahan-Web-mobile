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

class TimerModeScreen extends StatefulWidget {
  final String title;
  final int totalMinutes; // minimal 1 menit

  const TimerModeScreen({
    super.key,
    required this.title,
    required this.totalMinutes,
  });

  @override
  State<TimerModeScreen> createState() => _TimerModeScreenState();
}

class _TimerModeScreenState extends State<TimerModeScreen> {
  Timer? _timer;
  bool _running = false;

  late final int _totalSeconds;
  late int _remainSeconds;

  // ✅ stopwatch biar timer gak drift
  final Stopwatch _sw = Stopwatch();

  // ✅ biar suara countdown gak dobel
  int _lastSpokenSecond = -1;

  // buat health: catat start time saat beneran mulai
  DateTime? _startedAt;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.totalMinutes * 60;
    _remainSeconds = _totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sw.stop();
    super.dispose();
  }

  Future<void> _start() async {
    if (_running) return;

    _startedAt ??= DateTime.now();

    if (!_sw.isRunning) _sw.start();

    // ✅ suara mulai (tetep)
    if (appState.tts) {
      await TtsService.I.speak(
        "Mulai latihan. Durasi ${widget.totalMinutes} menit.",
        flush: true,
      );
    }

    setState(() => _running = true);

    // ✅ tick rapat supaya trigger suara lebih “nempel” sama detik
    _timer ??= Timer.periodic(const Duration(milliseconds: 50), (_) async {
      if (!mounted) return;

      final elapsed = _sw.elapsedMilliseconds ~/ 1000; // floor
      final newRemain = (_totalSeconds - elapsed).clamp(0, _totalSeconds);

      // kalau detik belum berubah, gak usah update
      if (newRemain == _remainSeconds) return;

      _remainSeconds = newRemain;

      // ✅ countdown hanya 10..1 (tanpa kalimat tambahan)
      if (appState.tts && _remainSeconds <= 10 && _remainSeconds >= 1) {
        if (_lastSpokenSecond != _remainSeconds) {
          _lastSpokenSecond = _remainSeconds;

          // 🔥 PENTING: flush TRUE biar gak ngantre → delay berkurang banyak
          await TtsService.I.speak("$_remainSeconds", flush: true);
        }
      }

      // selesai?
      if (_remainSeconds <= 0) {
        await _finish();
        return;
      }

      setState(() {});
    });
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;
    _sw.stop();
    setState(() => _running = false);
  }

  void _reset() {
    _timer?.cancel();
    _timer = null;

    _sw
      ..stop()
      ..reset();

    setState(() {
      _running = false;
      _remainSeconds = _totalSeconds;
      _lastSpokenSecond = -1;
      _startedAt = null;
    });
  }

  Future<void> _finish() async {
    _timer?.cancel();
    _timer = null;

    _sw
      ..stop()
      ..reset();

    setState(() => _running = false);

    // ✅ masuk history + laporan (AppState)
    appState.addWorkout(
      id: widget.title,
      nameId: widget.title,
      nameEn: widget.title,
      minutes: widget.totalMinutes,
    );

    // ✅ samain KKal dengan Laporan (8 kkal per menit)
    final int calories = widget.totalMinutes * 8;

    // ✅ masuk statistik (StatsScreen)
    await WorkoutHistoryService.addSession(
      minutes: widget.totalMinutes,
      calories: calories,
      score: widget.totalMinutes * 20,
    );

    // ✅ DATABASE: simpan ke Realtime Database (kalau user udah login)
    try {
      final start = _startedAt ??
          DateTime.now().subtract(Duration(minutes: widget.totalMinutes));
      final end = DateTime.now();

      await RtdbService.I.addSession(
        title: widget.title,
        category: "latihan",
        minutes: widget.totalMinutes,
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
      final start = _startedAt ??
          DateTime.now().subtract(Duration(minutes: widget.totalMinutes));
      final end = DateTime.now();

      await HealthSyncService.I.writeWorkout(
        title: widget.title,
        start: start,
        end: end,
        calories: calories,
      );
    }

    // ✅ suara selesai
    if (appState.tts) {
      await TtsService.I.speak("Latihan selesai. Bagus!", flush: true);
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Selesai! 🎉",
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text(
            "Latihan '${widget.title}' ${widget.totalMinutes} menit sudah dicatat ke Laporan."),
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
    final total = _totalSeconds;
    final progress = total == 0 ? 0.0 : (1 - (_remainSeconds / total));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Timer Mode",
            style: TextStyle(fontWeight: FontWeight.w900)),
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
                            Text(widget.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(
                              "Durasi • ${widget.totalMinutes} menit",
                              style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w700),
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
                            value: progress.clamp(0.0, 1.0),
                            backgroundColor: cs.surfaceContainerHighest,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(_fmt(_remainSeconds),
                          style: const TextStyle(
                              fontSize: 56, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _reset,
                              child: const Text("RESET",
                                  style: TextStyle(fontWeight: FontWeight.w900)),
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
                              child: Text(_running ? "PAUSE" : "START",
                                  style: const TextStyle(fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (!_running)
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: _finish,
                            child: const Text("Selesai sekarang (debug)",
                                style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        )
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
