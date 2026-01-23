import 'package:flutter/material.dart';
import '../../main.dart'; // ✅ biar bisa akses appState

class SettingsWorkoutScreen extends StatefulWidget {
  const SettingsWorkoutScreen({super.key});

  @override
  State<SettingsWorkoutScreen> createState() => _SettingsWorkoutScreenState();
}

class _SettingsWorkoutScreenState extends State<SettingsWorkoutScreen> {
  late String goal;
  late String level;
  late int restSec;
  late bool autoNext;

  @override
  void initState() {
    super.initState();

    // ✅ ambil nilai awal dari appState (biar tersimpan & kebaca lagi)
    goal = appState.workoutGoal;
    level = appState.workoutLevel;
    restSec = appState.workoutRestSec;
    autoNext = appState.workoutAutoNext;
  }

  void _save() {
    appState.setWorkoutSettings(
      goal: goal,
      level: level,
      restSec: restSec,
      autoNext: autoNext,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tersimpan ✅ (dipakai di semua halaman)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = const ["Fat Loss", "Muscle Gain", "Cardio", "Maintain"];
    final levels = const ["Pemula", "Menengah", "Lanjutan"];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pengaturan latihan",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Goal", style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: goal,
                    items: goals.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => goal = v ?? goal),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),

                  const Text("Level", style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: level,
                    items: levels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => level = v ?? level),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),

                  const Text("Waktu istirahat", style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text("$restSec detik", style: const TextStyle(fontWeight: FontWeight.w700)),
                  Slider(
                    value: restSec.toDouble(),
                    min: 10,
                    max: 120,
                    divisions: 11,
                    label: "$restSec",
                    onChanged: (v) => setState(() => restSec = v.round()),
                  ),

                  const Divider(height: 24),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: autoNext,
                    onChanged: (v) => setState(() => autoNext = v),
                    title: const Text("Auto Next", style: TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: const Text("Otomatis lanjut ke gerakan berikutnya"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: const Text("SIMPAN", style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ),
      ),
    );
  }
}
