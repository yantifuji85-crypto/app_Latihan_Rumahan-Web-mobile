import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../main.dart';
import '../app/app_state.dart';

class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  bool get _isEn => appState.language == "English";
  String _t(String id, String en) => _isEn ? en : id;

  String _fmtTime(DateTime t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  String _fmtDate(DateTime t) =>
      "${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}";

  Future<void> _inputWeight(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final c = TextEditingController();
    double? result;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        final isEn = appState.language == "English";
        String t(String id, String en) => isEn ? en : id;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t("Catat Berat Badan", "Log Weight"),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                t("Masukkan berat (kg)", "Enter weight (kg)"),
                style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: c,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: t("contoh: 68.5", "example: 68.5"),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B66FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  onPressed: () {
                    final txt = c.text.trim().replaceAll(',', '.');
                    final v = double.tryParse(txt);
                    if (v == null || v <= 0) return;
                    result = v;
                    Navigator.pop(context);
                  },
                  child: Text(
                    t("SIMPAN", "SAVE"),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );

    if (result != null) appState.addWeight(result!);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: appState,
      builder: (_, __) {
        final isEn = appState.language == "English";
        String t(String id, String en) => isEn ? en : id;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              t("Laporan", "Report"),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),

            // ✅ TAMBAH INI SAJA (tanpa ubah layout body)
            actions: [
              IconButton(
                tooltip: t("Statistik", "Stats"),
                icon: const Icon(Icons.show_chart_rounded),
                onPressed: () => Navigator.pushNamed(context, '/stats'),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
              children: [
                // ✅ SUMMARY CARD (persis model screenshot)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat(icon: Icons.emoji_events_rounded, value: "${appState.totalWorkout}", label: t("latihan", "workouts")),
                      _Stat(icon: Icons.local_fire_department_rounded, value: "${appState.totalKcal}", label: t("Kkal", "Kcal")),
                      _Stat(icon: Icons.access_time_rounded, value: "${appState.totalMinutes}", label: t("menit", "min")),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ✅ HISTORY HEADER
                Row(
                  children: [
                    Text(t("Riwayat", "History"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const Spacer(),
                    TextButton(onPressed: () {}, child: Text(t("Semua catatan", "All logs"))),
                  ],
                ),
                const SizedBox(height: 10),

                if (appState.history.isEmpty)
                  _EmptyHistoryCard(
                    title: t("Belum ada riwayat latihan.\nCoba mulai latihan dulu.", "No workout history yet.\nStart a workout first."),
                    buttonText: t("Mulai", "Start"),
                    onQuickStart: () => Navigator.pop(context),
                  )
                else
                  ...appState.history.take(10).map((h) {
                    final title = (h is WorkoutLog)
                        ? h.displayName(appState.language)
                        : (h as dynamic).name?.toString() ?? "-";

                    final unit = t("menit", "min");
                    final minutes = (h as dynamic).minutes ?? 0;
                    final time = (h as dynamic).time ?? DateTime.now();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.20)),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.fitness_center_rounded, color: cs.primary),
                        ),
                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                        subtitle: Text(
                          "$minutes $unit",
                          style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
                        ),
                        trailing: Text(_fmtTime(time), style: const TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    );
                  }),

                const SizedBox(height: 8),

                // ✅ BODY WEIGHT HEADER + BUTTON (persis screenshot)
                Row(
                  children: [
                    Text(t("Berat Badan", "Body Weight"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B66FF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      onPressed: () => _inputWeight(context),
                      child: Text(t("Catat", "Log"), style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ✅ WEIGHT CHART CARD (persis screenshot)
                _WeightChartCard(
                  chartTitle: t("Grafik", "Chart"),
                  footerText: t("Tampil maksimal 14 catatan terakhir", "Showing up to last 14 entries"),
                  emptyText: t("Belum ada data berat badan.\nKlik “Catat” buat mulai.", "No weight data yet.\nTap “Log” to start."),
                  weights: appState.weights,
                  latest: appState.latestWeight,
                  fmtDate: _fmtDate,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WeightChartCard extends StatelessWidget {
  final List<WeightLog> weights;
  final double? latest;
  final String Function(DateTime) fmtDate;

  final String emptyText;
  final String footerText;
  final String chartTitle;

  const _WeightChartCard({
    required this.weights,
    required this.latest,
    required this.fmtDate,
    required this.emptyText,
    required this.footerText,
    required this.chartTitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (weights.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.20)),
        ),
        alignment: Alignment.center,
        child: Text(
          emptyText,
          textAlign: TextAlign.center,
          style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w800),
        ),
      );
    }

    final list = weights.length > 14 ? weights.sublist(weights.length - 14) : weights;

    final spots = <FlSpot>[];
    double minY = double.infinity;
    double maxY = -double.infinity;

    for (var i = 0; i < list.length; i++) {
      final kg = list[i].kg;
      spots.add(FlSpot(i.toDouble(), kg));
      if (kg < minY) minY = kg;
      if (kg > maxY) maxY = kg;
    }

    final pad = ((maxY - minY) * 0.2).clamp(0.5, 3.0);
    final yMin = minY - pad;
    final yMax = maxY + pad;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(chartTitle, style: const TextStyle(fontWeight: FontWeight.w900)),
              const Spacer(),
              if (latest != null)
                Text(
                  "${latest!.toStringAsFixed(1)} kg",
                  style: TextStyle(color: cs.primary, fontWeight: FontWeight.w900),
                ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 170,
            child: LineChart(
              LineChartData(
                minY: yMin,
                maxY: yMax,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    strokeWidth: 1,
                    color: cs.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(
                        v.toStringAsFixed(0),
                        style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= list.length) return const SizedBox.shrink();
                        if (list.length > 6 && i % 3 != 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            fmtDate(list[i].time),
                            style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700, fontSize: 11),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    barWidth: 3,
                    color: cs.primary,
                    dotData: FlDotData(show: list.length <= 10),
                    belowBarData: BarAreaData(show: true, color: cs.primary.withValues(alpha: 0.12)),
                    spots: spots,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            footerText,
            style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistoryCard extends StatelessWidget {
  final VoidCallback onQuickStart;
  final String title;
  final String buttonText;

  const _EmptyHistoryCard({
    required this.onQuickStart,
    required this.title,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.history_rounded, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w900, height: 1.2),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onQuickStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B66FF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.w900)),
          )
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, color: cs.primary),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
