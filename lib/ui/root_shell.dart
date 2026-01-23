import 'package:flutter/material.dart';
import '../main.dart';

import 'screens/home_latihan.dart';
import 'screens/temukan.dart';
import 'screens/program.dart';
import 'screens/laporan.dart';
import 'screens/pengaturan.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int index = 0;

  bool get isEn => appState.language == "English";
  String t(String id, String en) => isEn ? en : id;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final pages = const [
      HomeLatihanScreen(),
      TemukanScreen(),
      ProgramScreen(),
      LaporanScreen(),
      PengaturanScreen(),
    ];

    return AnimatedBuilder(
      animation: appState, // ✅ penting: biar label ikut berubah realtime
      builder: (_, __) {
        return Scaffold(
          body: pages[index],

          bottomNavigationBar: NavigationBar(
            height: 74,
            selectedIndex: index,
            onDestinationSelected: (v) => setState(() => index = v),
            backgroundColor: cs.surface,
            indicatorColor: cs.surfaceContainerHighest.withValues(alpha: 0.55),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.fitness_center_outlined),
                selectedIcon: const Icon(Icons.fitness_center_rounded),
                label: t("Latihan", "Workout"),
              ),
              NavigationDestination(
                icon: const Icon(Icons.explore_outlined),
                selectedIcon: const Icon(Icons.explore_rounded),
                label: t("Temukan", "Discover"),
              ),
              NavigationDestination(
                icon: const Icon(Icons.grid_view_outlined),
                selectedIcon: const Icon(Icons.grid_view_rounded),
                label: t("Program", "Programs"),
              ),
              NavigationDestination(
                icon: const Icon(Icons.bar_chart_outlined),
                selectedIcon: const Icon(Icons.bar_chart_rounded),
                label: t("Laporan", "Report"),
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings_rounded),
                label: t("Pengaturan", "Settings"),
              ),
            ],
          ),
        );
      },
    );
  }
}
