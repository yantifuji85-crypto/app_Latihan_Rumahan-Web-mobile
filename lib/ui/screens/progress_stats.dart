import 'package:flutter/material.dart';

class ProgressImageScreen extends StatelessWidget {
  const ProgressImageScreen({super.key});

  // ✅ gambar statistik (bebas, ini contoh)
  static const String statImage =
      "https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=1200&q=80";

  // ✅ gambar cowok (kalo lu mau tampil juga di sini)
  static const String maleImage =
      "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80";

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget safeImage(String url) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, w, p) {
          if (p == null) return w;
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
            ),
          );
        },
        errorBuilder: (_, __, ___) {
          return Container(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
            alignment: Alignment.center,
            child: Icon(Icons.image_not_supported_rounded, color: cs.onSurfaceVariant.withValues(alpha: 0.8), size: 44),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistik", style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
          children: [
            // HEADER kecil dengan foto cowok
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: SizedBox(width: 44, height: 44, child: safeImage(maleImage)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Statistik latihan kamu",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // GAMBAR STATISTIK
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                height: 420,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
                ),
                child: safeImage(statImage),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
