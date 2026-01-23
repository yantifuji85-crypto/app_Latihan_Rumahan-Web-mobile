import 'dart:async';
import 'package:flutter/material.dart';

class WorkoutStep {
  final String name;
  final int seconds; // durasi per gerakan (minimal 60 kalau mau)
  final String note;

  const WorkoutStep({
    required this.name,
    required this.seconds,
    this.note = "",
  });
}

class WorkoutStepsScreen extends StatefulWidget {
  final String title;
  final List<WorkoutStep> steps;
  final int restSecondsBetweenSteps;

  const WorkoutStepsScreen({
    super.key,
    required this.title,
    required this.steps,
    this.restSecondsBetweenSteps = 15,
  });

  @override
  State<WorkoutStepsScreen> createState() => _WorkoutStepsScreenState();
}

class _WorkoutStepsScreenState extends State<WorkoutStepsScreen> {
  Timer? _timer;
  bool _running = false;

  int _index = 0;
  bool _isRest = false;

  late int _remain;

  int get _safeStepSeconds {
    final s = widget.steps[_index].seconds;
    return s < 60 ? 60 : s; // ✅ min 1 menit per gerakan
  }

  int get _safeRest => widget.restSecondsBetweenSteps < 5 ? 5 : widget.restSecondsBetweenSteps;

  @override
  void initState() {
    super.initState();
    _remain = _safeStepSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (_running) return;
    setState(() => _running = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        if (_remain > 0) {
          _remain--;
          return;
        }
        _nextPhase();
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;
    setState(() => _running = false);
  }

  void _reset() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _running = false;
      _index = 0;
      _isRest = false;
      _remain = _safeStepSeconds;
    });
  }

  void _skip() {
    setState(() => _nextPhase(force: true));
  }

  void _nextPhase({bool force = false}) {
    if (!_isRest) {
      // selesai gerakan -> masuk rest (kalau bukan step terakhir)
      if (_index < widget.steps.length - 1) {
        _isRest = true;
        _remain = _safeRest;
        return;
      }
      _finish();
      return;
    } else {
      // selesai rest -> next step
      _isRest = false;
      _index += 1;
      _remain = _safeStepSeconds;
    }
  }

  void _finish() {
    _timer?.cancel();
    _timer = null;
    _running = false;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Selesai! 🎉", style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text("Workout hari ini beres. Mantap!"),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); _reset(); }, child: const Text("Ulangi")),
          ElevatedButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text("Kembali")),
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
    final total = _isRest ? _safeRest : _safeStepSeconds;
    final progress = total == 0 ? 0.0 : (1 - (_remain / total));

    final currentTitle = _isRest ? "ISTIRAHAT" : widget.steps[_index].name;
    final badgeColor = _isRest ? const Color(0xFF22C55E) : const Color(0xFF0B66FF);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              Card(
                elevation: 0,
                color: cs.surfaceContainerHighest.withOpacity(0.55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _isRest ? "REST" : "WORK",
                          style: TextStyle(fontWeight: FontWeight.w900, color: badgeColor),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          currentTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Text(
                        "${_index + 1}/${widget.steps.length}",
                        style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                clipBehavior: Clip.antiAlias,
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
                            backgroundColor: const Color(0xFFE9EDF2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(_fmt(_remain), style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text(
                        _isRest ? "Ambil napas dulu 😮‍💨" : (widget.steps[_index].note.isEmpty ? "Fokus teknik 💪" : widget.steps[_index].note),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _reset,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text("RESET", style: TextStyle(fontWeight: FontWeight.w900)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _running ? _pause : _start,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: badgeColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(_running ? "PAUSE" : "START", style: const TextStyle(fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: _skip,
                        icon: const Icon(Icons.skip_next),
                        label: const Text("Lewati", style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // List preview biar terasa app nyata
              Expanded(
                child: ListView.separated(
                  itemCount: widget.steps.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final isNow = (!_isRest && i == _index);
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withOpacity(isNow ? 0.85 : 0.55),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: (isNow ? const Color(0xFF0B66FF) : cs.primary).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.play_circle_outline, color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(widget.steps[i].name, style: const TextStyle(fontWeight: FontWeight.w900)),
                          ),
                          Text(
                            "${(widget.steps[i].seconds < 60 ? 60 : widget.steps[i].seconds)}s",
                            style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
