import 'package:flutter/material.dart';

import '../../data/firestore_service.dart';
import '../../data/models/weekly_plan.dart';

class WeeklyPlanScreen extends StatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  final fs = FirestoreService.instance;

  @override
  void initState() {
    super.initState();
    // ✅ bikin default plan kalau belum ada
    fs.ensureDefaultWeeklyPlan();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Workout Plan Mingguan",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<WeeklyDayPlan>>(
          stream: fs.watchWeeklyPlan(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final days = snap.data ?? [];
            if (days.isEmpty) {
              return Center(
                child: Text(
                  "Plan belum ada.\nCoba restart / reload.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final d = days[i];

                final stepsText = d.steps.isEmpty
                    ? "-"
                    : d.steps.map((e) => "${e.name} (${e.seconds}s)").join(" • ");

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    title: Text(
                      "Day ${d.day} • ${d.title}",
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      "${d.level}\n$stepsText",
                      style: const TextStyle(fontWeight: FontWeight.w700, height: 1.2),
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Nanti: start workout dari ${d.title}")),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
