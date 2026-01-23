import 'package:flutter/material.dart';
import '../../main.dart';
import 'item_detail.dart';
import 'search_screen.dart'; // ✅ icon search
import 'laporan.dart';      // ✅ icon jam -> LaporanScreen

class TemukanScreen extends StatelessWidget {
  const TemukanScreen({super.key});

  bool get _isEnglish => appState.language == "English";

  String _t(String id, String en) => _isEnglish ? en : id;

  void _openSearch(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
  }

  void _openLaporan(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporanScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: appState,
      builder: (_, __) {
        final isEnglish = appState.language == "English";
        String t(String id, String en) => isEnglish ? en : id;

        return SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            children: [
              Row(
                children: [
                  Text(
                    t("TEMUKAN", "DISCOVER"),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),

                  // ✅ buka SearchScreen
                  IconButton(
                    onPressed: () => _openSearch(context),
                    icon: const Icon(Icons.search),
                  ),

                  // ✅ buka LaporanScreen
                  IconButton(
                    onPressed: () => _openLaporan(context),
                    icon: const Icon(Icons.access_time),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                t("Untuk pemula", "For beginners"),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 130,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final data = [
                      (
                      t("Hanya 4 Gerakan\nuntuk Otot Perut", "Only 4 Moves\nfor Abs"),
                      "https://images.pexels.com/photos/416778/pexels-photo-416778.jpeg?auto=compress&cs=tinysrgb&w=1200"
                      ),
                      (
                      t("Latihan Kaki\nTanpa Melompat", "Leg Workout\nNo Jumping"),
                      "https://images.pexels.com/photos/1552242/pexels-photo-1552242.jpeg?auto=compress&cs=tinysrgb&w=1200"
                      ),
                      (
                      t("Latihan\nTanpa Alat", "No Equipment\nWorkout"),
                      "https://images.pexels.com/photos/2261477/pexels-photo-2261477.jpeg?auto=compress&cs=tinysrgb&w=1200"
                      ),
                    ][i];

                    return _MiniPosterCard(
                      title: data.$1,
                      imageUrl: data.$2,
                      onTap: () {
                        _pushFade(
                          context,
                          ItemDetailScreen(
                            section: t("Untuk pemula", "For beginners"),
                            title: data.$1,
                            subtitle: t("Rekomendasi latihan untuk pemula", "Recommended workouts for beginners"),
                            imageUrl: data.$2,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),
              Text(
                t("Latihan cepat", "Quick workouts"),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),

              _QuickTile(
                title: t("Tabata 4 Menit", "4-Min Tabata"),
                subtitle: t("4 menit • Menengah", "4 min • Intermediate"),
                imageUrl:
                "https://images.pexels.com/photos/1552106/pexels-photo-1552106.jpeg?auto=compress&cs=tinysrgb&w=1200",
                rightImg:
                "https://images.pexels.com/photos/2780762/pexels-photo-2780762.jpeg?auto=compress&cs=tinysrgb&w=400",
                onTap: () {
                  _pushFade(
                    context,
                    ItemDetailScreen(
                      section: t("Latihan cepat", "Quick workouts"),
                      title: t("Tabata 4 Menit", "4-Min Tabata"),
                      subtitle: t("4 menit • Menengah", "4 min • Intermediate"),
                      imageUrl:
                      "https://images.pexels.com/photos/1552106/pexels-photo-1552106.jpeg?auto=compress&cs=tinysrgb&w=1200",
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _QuickTile(
                title: t("3 Latihan Singkirkan Lemak\nPerut", "3 Workouts to Reduce\nBelly Fat"),
                subtitle: t("6 menit • Pemula", "6 min • Beginner"),
                imageUrl:
                "https://images.pexels.com/photos/1552106/pexels-photo-1552106.jpeg?auto=compress&cs=tinysrgb&w=1200",
                rightImg:
                "https://images.pexels.com/photos/4056723/pexels-photo-4056723.jpeg?auto=compress&cs=tinysrgb&w=400",
                onTap: () {
                  _pushFade(
                    context,
                    ItemDetailScreen(
                      section: t("Latihan cepat", "Quick workouts"),
                      title: t("3 Latihan Singkirkan Lemak Perut", "3 Workouts to Reduce Belly Fat"),
                      subtitle: t("6 menit • Pemula", "6 min • Beginner"),
                      imageUrl:
                      "https://images.pexels.com/photos/3757376/pexels-photo-3757376.jpeg?auto=compress&cs=tinysrgb&w=1200",
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),
              Text(
                t("Tantangan", "Challenges"),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 120,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final items = [
                      (
                      t("Latihan Dada", "Chest Workout"),
                      "https://images.pexels.com/photos/1552249/pexels-photo-1552249.jpeg?auto=compress&cs=tinysrgb&w=1200"
                      ),
                      (
                      t("HIIT Sixpack", "HIIT Sixpack"),
                      "https://images.pexels.com/photos/2261485/pexels-photo-2261485.jpeg?auto=compress&cs=tinysrgb&w=1200"
                      ),
                      (
                      t("Full Body", "Full Body"),
                      "https://images.pexels.com/photos/3763871/pexels-photo-3763871.jpeg?auto=compress&cs=tinysrgb&w=1200"
                      ),
                    ][i];

                    return _TantanganPoster(
                      title: items.$1,
                      imageUrl: items.$2,
                      onTap: () {
                        _pushFade(
                          context,
                          ItemDetailScreen(
                            section: t("Tantangan", "Challenges"),
                            title: items.$1,
                            subtitle: t("Challenge untuk hasil maksimal", "Challenge for maximum results"),
                            imageUrl: items.$2,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ✅ helper navigasi: transisi fade halus
void _pushFade(BuildContext context, Widget page) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        final a = CurvedAnimation(parent: anim, curve: Curves.easeOut);
        return FadeTransition(opacity: a, child: child);
      },
    ),
  );
}

/// ✅ gambar aman + dark mode aman (pakai theme)
Widget safeImage(
    BuildContext context,
    String url, {
      BoxFit fit = BoxFit.cover,
      double? width,
      double? height,
      BorderRadius? radius,
    }) {
  final cs = Theme.of(context).colorScheme;

  final img = Image.network(
    url,
    width: width,
    height: height,
    fit: fit,
    loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return Container(
        width: width,
        height: height,
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        alignment: Alignment.center,
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
        ),
      );
    },
    errorBuilder: (_, __, ___) => Container(
      width: width,
      height: height,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
      alignment: Alignment.center,
      child: Icon(Icons.image_not_supported, color: cs.onSurfaceVariant.withValues(alpha: 0.8)),
    ),
  );

  if (radius != null) return ClipRRect(borderRadius: radius, child: img);
  return img;
}

class _MiniPosterCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const _MiniPosterCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: 170,
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              safeImage(context, imageUrl),
              Container(color: Colors.black.withValues(alpha: 0.28)),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String rightImg;
  final VoidCallback onTap;

  const _QuickTile({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.rightImg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              safeImage(
                context,
                imageUrl,
                width: 64,
                height: 64,
                radius: BorderRadius.circular(14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              safeImage(
                context,
                rightImg,
                width: 64,
                height: 64,
                radius: BorderRadius.circular(14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TantanganPoster extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const _TantanganPoster({
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: 170,
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              safeImage(context, imageUrl),
              Container(color: Colors.black.withValues(alpha: 0.25)),
              Positioned(
                left: 12,
                bottom: 12,
                right: 12,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
