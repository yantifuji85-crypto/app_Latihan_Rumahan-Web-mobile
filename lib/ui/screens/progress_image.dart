import 'package:flutter/material.dart';
import 'stats_screen.dart';

class ProgressImageScreen extends StatelessWidget {
  const ProgressImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: jangan tampilkan gambar statistik lagi
    // langsung tampilkan halaman statistik beneran (grafik)
    return const StatsScreen();
  }
}
