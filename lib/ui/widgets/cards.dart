import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CoachCard extends StatelessWidget {
  const CoachCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                  "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80"),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Hai, temanku! Ayo terus kejar\ntujuanmu!",
                style: TextStyle(
                  height: 1.15,
                  color: Colors.black.withOpacity(0.75),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChallengeBigCard extends StatelessWidget {
  final VoidCallback onTap;
  const ChallengeBigCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const img =
        "https://images.unsplash.com/photo-1599058917212-d750089bc07e?auto=format&fit=crop&w=1200&q=80";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF0B66FF), Color(0xFF0B66FF), Color(0xFF0A4ED6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.45,
                  child: CachedNetworkImage(imageUrl: img, fit: BoxFit.cover),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.05), Colors.black.withOpacity(0.35)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("28 HARI",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    const Text(
                      "TANTANGAN\nSELURUH TUBUH",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Expanded(
                      child: Text(
                        "Mulailah perjalanan membentuk tubuh dengan\nfokus pada semua kelompok otot dan bangun\ntubuh impianmu dalam 4 minggu!",
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0B66FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 0,
                        ),
                        onPressed: onTap,
                        child: const Text("MULAI",
                            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
