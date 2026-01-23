import 'package:flutter/material.dart';
import 'timer_setup.dart'; // ✅ GANTI: buka halaman pilih durasi

class TantanganDetailScreen extends StatelessWidget {
  final String section;
  final String title;
  final String subtitle;
  final String imageUrl;

  const TantanganDetailScreen({
    super.key,
    this.section = "Tantangan",
    this.title = "Full Body Burn • 28 Hari",
    this.subtitle =
    "Program 28 hari buat bentuk badan lebih atletis. "
        "Latihan singkat, progresif, dan aman — cukup bodyweight, tanpa alat.",
    this.imageUrl =
    "https://images.unsplash.com/photo-1554284126-aa88f22d8b74?auto=format&fit=crop&w=1400&q=80",
  });

  void _startTimerSetup(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TimerSetupScreen(title: title), // ✅ pilih durasi 1 menit+
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            backgroundColor: cs.surface,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(section, style: const TextStyle(fontWeight: FontWeight.w900)),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover),
                  Container(color: Colors.black.withOpacity(0.35)),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 18,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Text(
                subtitle,
                style: TextStyle(
                  color: cs.onSurface.withOpacity(0.72),
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF0B66FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              onPressed: () => _startTimerSetup(context), // ✅ FIX
              child: const Text(
                "MULAI LATIHAN",
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
