import 'dart:async';
import 'package:flutter/material.dart';

class SplashLikeScreen extends StatefulWidget {
  const SplashLikeScreen({super.key});

  @override
  State<SplashLikeScreen> createState() => _SplashLikeScreenState();
}

class _SplashLikeScreenState extends State<SplashLikeScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/root');
    });
  }

  @override
  Widget build(BuildContext context) {
    // GANTI ini pakai cover dari Firebase Storage kalau mau
    const bgUrl =
        "https://images.unsplash.com/photo-1599058917212-d750089bc07e?auto=format&fit=crop&w=1200&q=80";

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(bgUrl, fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.45)),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.fitness_center, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ENERGY & PERSISTENCE",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5)),
                        SizedBox(height: 4),
                        Text("CONQUER ALL THINGS",
                            style: TextStyle(color: Colors.white70, letterSpacing: 2)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: const LinearProgressIndicator(minHeight: 6),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
