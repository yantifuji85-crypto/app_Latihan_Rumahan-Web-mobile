import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:latihan_rumahan/data/workout_session.dart';
import 'package:latihan_rumahan/data/services/workout_history_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    // ❌ JANGAN seed demo kalau mau akurat
    // WorkoutHistoryService.seedDemoIfEmpty();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistik"),
      ),
      body: StreamBuilder<List<WorkoutSession>>(
        stream: WorkoutHistoryService.watchSessions(),
        builder: (context, snap) {
          final sessions = snap.data ?? <WorkoutSession>[];
          final series = _aggregateDailyLast14(sessions);

          final int totalSessions = sessions.length;
          final int totalMinutes = sessions.fold<int>(0, (a, s) => a + s.minutes);
          final int totalCalories = sessions.fold<int>(0, (a, s) => a + s.calories);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: cs.primary.withOpacity(0.15),
                      child: const Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Statistik latihan kamu",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _MiniStat(title: "Sesi", value: "$totalSessions")),
                  const SizedBox(width: 10),
                  Expanded(child: _MiniStat(title: "Menit", value: "$totalMinutes")),
                  const SizedBox(width: 10),
                  Expanded(child: _MiniStat(title: "Kalori", value: "$totalCalories")),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Progress 14 Hari Terakhir",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 210,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 34),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 2,
                                getTitlesWidget: (value, meta) {
                                  final i = value.toInt();
                                  if (i < 0 || i >= series.length) return const SizedBox.shrink();
                                  final d = series[i].date;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      "${d.day}/${d.month}",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: cs.onSurfaceVariant,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                for (int i = 0; i < series.length; i++)
                                  FlSpot(i.toDouble(), series[i].value.toDouble()),
                              ],
                              isCurved: true,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Tip: setiap kali kamu selesai workout, data sesi disimpan → grafik otomatis naik.",
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ✅ tombol simulasi tetap ada (UI ga berubah)
              FilledButton.icon(
                onPressed: () async {
                  await WorkoutHistoryService.addSession(
                    minutes: 15 + (sessions.length % 10),
                    calories: 90 + (sessions.length % 10) * 8,
                    score: 200 + (sessions.length % 10) * 25,
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Simulasi: Tambah 1 Sesi (Grafik Naik)"),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_DayPoint> _aggregateDailyLast14(List<WorkoutSession> sessions) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 13));

    final map = <DateTime, int>{};
    for (int i = 0; i < 14; i++) {
      final d = start.add(Duration(days: i));
      map[DateTime(d.year, d.month, d.day)] = 0;
    }

    for (final s in sessions) {
      final d = DateTime(s.at.year, s.at.month, s.at.day);
      if (d.isBefore(start)) continue;
      if (!map.containsKey(d)) continue;
      map[d] = (map[d] ?? 0) + s.minutes;
    }

    final keys = map.keys.toList()..sort((a, b) => a.compareTo(b));
    return [for (final k in keys) _DayPoint(date: k, value: map[k] ?? 0)];
  }
}

class _DayPoint {
  final DateTime date;
  final int value;
  _DayPoint({required this.date, required this.value});
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;
  const _MiniStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
