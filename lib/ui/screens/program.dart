import 'package:flutter/material.dart';

import '../../main.dart';
import '../../data/workout_data.dart'; // ✅ FIX: kItems (sebelumnya salah path)
import 'item_detail.dart';
import 'timer_mode.dart';

class ProgramScreen extends StatelessWidget {
  const ProgramScreen({super.key});

  // ✅ fallback foto gym keren kalau image item error/kosong
  static const String _fallbackGymImg =
      "https://images.pexels.com/photos/1552106/pexels-photo-1552106.jpeg?auto=compress&cs=tinysrgb&w=1200";

  bool get _isEnglish => appState.language == "English";
  String _t(String id, String en) => _isEnglish ? en : id;

  // ✅ image aman: loading + fallback (keren)
  Widget _safeNetImage(
      BuildContext context,
      String? url, {
        double? w,
        double? h,
      }) {
    final cs = Theme.of(context).colorScheme;
    final finalUrl =
    (url == null || url.trim().isEmpty) ? _fallbackGymImg : url.trim();

    return Image.network(
      finalUrl,
      width: w,
      height: h,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: w,
          height: h,
          color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
          alignment: Alignment.center,
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
          ),
        );
      },
      errorBuilder: (_, __, ___) {
        // kalau URL item error, coba fallback gym sekali lagi
        return Image.network(
          _fallbackGymImg,
          width: w,
          height: h,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            // kalau fallback juga error (jarang), kasih icon
            return Container(
              width: w,
              height: h,
              color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
              alignment: Alignment.center,
              child: Icon(
                Icons.fitness_center_rounded,
                color: cs.onSurfaceVariant.withValues(alpha: 0.75),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: appState,
      builder: (_, __) {
        // program
        final programs = kItems.where((e) => e.category == "program").toList();

        // ✅ FIX: workouts ambil semua selain program biar gak kosong
        final workouts = kItems.where((e) => e.category != "program").toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _t("Program", "Programs"),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.grid_view_rounded, color: cs.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t("Daftar Program", "Program List"),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _t(
                                "Riwayat: ${appState.totalWorkout} latihan • ${appState.totalMinutes} menit",
                                "History: ${appState.totalWorkout} workouts • ${appState.totalMinutes} min",
                              ),
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

                const SizedBox(height: 14),

                // ======================
                // PROGRAM LIST
                // ======================
                if (programs.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32, bottom: 18),
                      child: Text(
                        _t("Belum ada program.", "No programs yet."),
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  )
                else
                  ...programs.map((it) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemDetailScreen(
                                section: _t("PROGRAM", "PROGRAM"),
                                title: it.title,
                                subtitle: it.subtitle,
                                imageUrl: it.imageUrl,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                            cs.surfaceContainerHighest.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: _safeNetImage(
                                  context,
                                  it.imageUrl,
                                  w: 72,
                                  h: 72,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      it.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      it.subtitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _t(
                                        "program • ${it.defaultMinutes} menit",
                                        "program • ${it.defaultMinutes} min",
                                      ),
                                      style: TextStyle(
                                        color: cs.primary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: cs.onSurfaceVariant),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                // ======================
                // WORKOUTS
                // ======================
                const SizedBox(height: 10),
                Text(
                  _t("Latihan", "Workouts"),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),

                if (workouts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 18),
                    child: Text(
                      _t("Belum ada latihan.", "No workouts yet."),
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  ...workouts.map((it) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemDetailScreen(
                                section: _t("LATIHAN", "WORKOUT"),
                                title: it.title,
                                subtitle: it.subtitle,
                                imageUrl: it.imageUrl,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                            cs.surfaceContainerHighest.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: _safeNetImage(
                                  context,
                                  it.imageUrl,
                                  w: 72,
                                  h: 72,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      it.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      it.subtitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _t(
                                        "workout • ${it.defaultMinutes} menit",
                                        "workout • ${it.defaultMinutes} min",
                                      ),
                                      style: TextStyle(
                                        color: cs.primary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: cs.onSurfaceVariant),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                // ======================
                // ✅ START PROGRAM PALING BAWAH
                // ======================
                const SizedBox(height: 14),
                if (programs.isNotEmpty)
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B66FF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      onPressed: () {
                        final it = programs.first;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TimerModeScreen(
                              title: it.title,
                              totalMinutes: it.defaultMinutes,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        _t("MULAI PROGRAM", "START PROGRAM"),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
