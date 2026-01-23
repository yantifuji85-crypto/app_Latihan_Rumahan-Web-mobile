import 'package:flutter/material.dart';
import 'timer_mode.dart';

class TimerSetupScreen extends StatefulWidget {
  final String title;

  const TimerSetupScreen({
    super.key,
    this.title = "Timer Cepat", // ✅ default
  });

  @override
  State<TimerSetupScreen> createState() => _TimerSetupScreenState();
}

class _TimerSetupScreenState extends State<TimerSetupScreen> {
  int selectedMinutes = 1;

  final List<int> presets = const [1, 2, 3, 5, 10, 15, 20, 30];

  void _start() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TimerModeScreen(
          title: widget.title,
          totalMinutes: selectedMinutes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pilih Durasi",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.title,
                                style: const TextStyle(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 6),
                            Text(
                              "Pilih durasi mulai dari 1 menit",
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: presets.map((m) {
                        final selected = selectedMinutes == m;
                        return ChoiceChip(
                          label: Text("$m menit",
                              style: const TextStyle(fontWeight: FontWeight.w900)),
                          selected: selected,
                          selectedColor: const Color(0xFF0B66FF),
                          labelStyle: TextStyle(color: selected ? Colors.white : null),
                          onSelected: (_) => setState(() => selectedMinutes = m),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Custom",
                                style: TextStyle(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Slider(
                                    min: 1,
                                    max: 60,
                                    divisions: 59,
                                    value: selectedMinutes.toDouble(),
                                    onChanged: (v) =>
                                        setState(() => selectedMinutes = v.round()),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    "$selectedMinutes m",
                                    style: const TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

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
                        onPressed: _start,
                        child: const Text(
                          "MULAI TIMER",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
