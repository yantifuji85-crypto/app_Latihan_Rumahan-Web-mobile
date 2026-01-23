import 'package:flutter/material.dart';

import '../../main.dart'; // ✅ ambil appState.language
import 'laporan.dart';
import 'timer_mode.dart';
import 'search_screen.dart';
import 'progress_image.dart'; // ✅ halaman progres gambar

// ✅ TAMBAH INI (Stopwatch jogging)
import 'stopwatch_mode.dart';

class HomeLatihanScreen extends StatelessWidget {
  const HomeLatihanScreen({super.key});

  void _openSearch(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
  }

  // ✅ buka Search dengan query awal (buat Focus Card / Category)
  void _openSearchWithQuery(BuildContext context, String q) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(initialQuery: q),
      ),
    );
  }

  // ✅ SHEET PILIH MODE TIMER (latihan / jogging)
  Future<void> _openTimerChooser(BuildContext context) async {
    final nav = Navigator.of(context);

    final String? picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _TimerChooserSheet(),
    );

    if (picked == null) return;

    // 1) Countdown (latihan)
    if (picked == "countdown") {
      final int? minutes = await showModalBottomSheet<int>(
        context: context,
        showDragHandle: true,
        builder: (_) => const _QuickMinuteSheet(),
      );

      if (minutes == null) return;

      nav.push(
        MaterialPageRoute(
          builder: (_) => TimerModeScreen(title: "Timer Cepat", totalMinutes: minutes),
        ),
      );
      return;
    }

    // 2) Stopwatch (jogging)
    if (picked == "stopwatch") {
      nav.push(
        MaterialPageRoute(
          builder: (_) => const StopwatchModeScreen(title: "Jogging"),
        ),
      );
      return;
    }
  }

  // ✅ countdown juga dipakai buat GAS (weekly)
  Future<void> _openTimerQuickCountdown(BuildContext context) async {
    final nav = Navigator.of(context);

    final int? minutes = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _QuickMinuteSheet(),
    );

    if (minutes == null) return;

    nav.push(
      MaterialPageRoute(
        builder: (_) => TimerModeScreen(title: "Timer Cepat", totalMinutes: minutes),
      ),
    );
  }

  void _openLaporan(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporanScreen()));
  }

  // ✅ Progres = buka gambar statistik
  void _openProgress(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressImageScreen()));
  }

  // ✅ FIX: Tantangan juga pilih menit mulai dari 1 menit
  Future<void> _startChallenge(BuildContext context) async {
    final nav = Navigator.of(context);

    final int? minutes = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _QuickMinuteSheet(),
    );

    if (minutes == null) return;

    nav.push(
      MaterialPageRoute(
        builder: (_) => TimerModeScreen(
          title: "Tantangan Seluruh Tubuh",
          totalMinutes: minutes,
        ),
      ),
    );
  }

  Future<void> _editWeeklyGoal(BuildContext context) async {
    final isEn = appState.language == "English";
    String t(String id, String en) => isEn ? en : id;

    final int? goal = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) => _WeeklyGoalSheet(
        title: t("Target Mingguan", "Weekly Target"),
        current: appState.weeklyGoal,
      ),
    );

    if (goal == null) return;
    appState.setWeeklyGoal(goal);
  }

  Future<void> _pickAvatar(BuildContext context) async {
    final String? url = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _AvatarPickerSheet(),
    );

    if (url == null) return;
    appState.setAvatarUrl(url);
  }

  Future<void> _pickCategory(BuildContext context) async {
    final isEn = appState.language == "English";
    String t(String id, String en) => isEn ? en : id;

    final String? picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => _CategorySheet(
        title: t("Pilih kategori", "Choose category"),
        items: [
          t("Otot perut (Abs)", "Abs"),
          t("Lengan (Arms)", "Arms"),
          t("Dada (Chest)", "Chest"),
          t("Kaki (Legs)", "Legs"),
          t("Bahu (Shoulders)", "Shoulders"),
          t("Punggung (Back)", "Back"),
          t("Full Body", "Full Body"),
        ],
      ),
    );

    if (picked == null) return;
    if (!context.mounted) return;

    final lower = picked.toLowerCase();
    String q = picked;
    if (lower.contains("abs") || lower.contains("perut") || lower.contains("core")) q = "core";
    if (lower.contains("arms") || lower.contains("lengan")) q = "lengan";
    if (lower.contains("chest") || lower.contains("dada")) q = "dada";
    if (lower.contains("legs") || lower.contains("kaki")) q = "kaki";
    if (lower.contains("shoulders") || lower.contains("bahu")) q = "bahu";
    if (lower.contains("back") || lower.contains("punggung")) q = "punggung";
    if (lower.contains("full body")) q = "full body";

    _openSearchWithQuery(context, q);
  }

  // ✅ HITUNG PROGRESS MINGGU INI dari appState.history
  int _currentWeeklyCount() {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final nextMonday = monday.add(const Duration(days: 7));

    // appState.history berisi WorkoutLog(time: ...)
    return appState.history.where((e) {
      return e.time.isAfter(monday.subtract(const Duration(milliseconds: 1))) && e.time.isBefore(nextMonday);
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final isEn = appState.language == "English";
    String t(String id, String en) => isEn ? en : id;

    return AnimatedBuilder(
      animation: appState,
      builder: (_, __) {
        final currentWeekly = _currentWeeklyCount();

        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
              children: [
                // SEARCH BAR
                InkWell(
                  onTap: () => _openSearch(context),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: cs.onSurfaceVariant.withValues(alpha: 0.9)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t("Cari latihan, program, tantangan…", "Search workouts, programs, challenges…"),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Icon(Icons.tune_rounded, color: cs.onSurfaceVariant.withValues(alpha: 0.9)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // QUICK CARDS
                Row(
                  children: [
                    Expanded(
                      child: _QuickCardBig(
                        title: t("Timer", "Timer"),
                        subtitle: t("Mulai\ncepat", "Quick\nstart"),
                        icon: Icons.timer_rounded,
                        // ✅ sekarang muncul pilihan: latihan/jogging
                        onTap: () => _openTimerChooser(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickCardBig(
                        title: t("Progres", "Progress"),
                        subtitle: t("Lihat\nstatistik", "View\nstats"),
                        icon: Icons.auto_graph_rounded,
                        onTap: () => _openProgress(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // TARGET MINGGUAN
                _WeeklyTargetCard(
                  current: currentWeekly,
                  goal: appState.weeklyGoal,
                  onEdit: () => _editWeeklyGoal(context),
                  // gas tetap countdown (latihan)
                  onGas: () => _openTimerQuickCountdown(context),
                  avatarUrl: appState.avatarUrl,
                  onAvatarTap: () => _pickAvatar(context),
                  titleText: t("Target Mingguan", "Weekly Target"),
                  greetText: t(
                    "Hai, temanku! Ayo terus kejar\ntujuanmu 🔥",
                    "Hey buddy! Keep chasing\nyour goal 🔥",
                  ),
                  gasText: t("Gas!", "Go!"),
                ),

                const SizedBox(height: 16),

                // HEADER TANTANGAN
                Row(
                  children: [
                    Text(
                      t("Tantangan", "Challenge"),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _openSearch(context),
                      child: Text(t("Lihat semua", "See all")),
                    ),
                    Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                  ],
                ),

                const SizedBox(height: 10),

                // HERO CHALLENGE
                _ChallengeHeroCard(
                  daysBadge: t("28 HARI", "28 DAYS"),
                  title: t("TANTANGAN\nSELURUH TUBUH", "FULL BODY\nCHALLENGE"),
                  subtitle: t(
                    "Full body plan progresif untuk membentuk\notot & stamina.",
                    "Progressive full body plan to build\nmuscle & stamina.",
                  ),
                  imageUrl:
                  "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=1400&q=80",
                  onStart: () => _startChallenge(context),
                  onTapCard: () => _startChallenge(context),
                  startText: t("MULAI", "START"),
                ),

                const SizedBox(height: 18),

                // FOKUS TUBUH
                Text(
                  t("Fokus Tubuh", "Body Focus"),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _FocusCard(
                        title: t("Core", "Core"),
                        subtitle: t("Perut & inti", "Abs & core"),
                        icon: Icons.event_seat_rounded,
                        onTap: () => _openSearchWithQuery(context, "core"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FocusCard(
                        title: t("Upper", "Upper"),
                        subtitle: t("Dada &\nlengan", "Chest &\narms"),
                        icon: Icons.sports_martial_arts_rounded,
                        onTap: () => _openSearchWithQuery(context, "upper"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _FocusCard(
                        title: t("Lower", "Lower"),
                        subtitle: t("Kaki &\nglutes", "Legs &\n glutes"),
                        icon: Icons.directions_run_rounded,
                        onTap: () => _openSearchWithQuery(context, "kaki"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FocusCard(
                        title: t("Cardio", "Cardio"),
                        subtitle: t("Stamina &\nfatburn", "Stamina &\nfat burn"),
                        icon: Icons.bolt_rounded,
                        onTap: () => _openSearchWithQuery(context, "cardio"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                _AddCategoryCard(
                  text: t(
                    "Tambah kategori lain: Otot perut,\nLengan, Dada, Kaki.",
                    "Add more categories: Abs,\nArms, Chest, Legs.",
                  ),
                  onTap: () => _pickCategory(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NetImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? radius;

  const _NetImage({
    required this.url,
    this.width,
    this.height,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget child = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, w, p) {
        if (p == null) return w;
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
      errorBuilder: (_, __, ___) {
        return Container(
          width: width,
          height: height,
          color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
          alignment: Alignment.center,
          child: Icon(Icons.person, color: cs.onSurfaceVariant.withValues(alpha: 0.85)),
        );
      },
    );

    if (radius != null) {
      child = ClipRRect(borderRadius: radius!, child: child);
    }
    return child;
  }
}

class _QuickCardBig extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickCardBig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        height: 92,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: cs.primary.withValues(alpha: 0.95)),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, color: cs.onSurfaceVariant.withValues(alpha: 0.8)),
          ],
        ),
      ),
    );
  }
}

class _WeeklyTargetCard extends StatelessWidget {
  final int current;
  final int goal;
  final VoidCallback onEdit;
  final VoidCallback onGas;

  final String avatarUrl;
  final VoidCallback onAvatarTap;

  final String titleText;
  final String greetText;
  final String gasText;

  const _WeeklyTargetCard({
    required this.current,
    required this.goal,
    required this.onEdit,
    required this.onGas,
    required this.avatarUrl,
    required this.onAvatarTap,
    this.titleText = "Target Mingguan",
    this.greetText = "Hai, temanku! Ayo terus kejar\ntujuanmu 🔥",
    this.gasText = "Gas!",
  });

  List<int> _weekDays(DateTime now) {
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)).day);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final now = DateTime.now();
    final days = _weekDays(now);
    final activeDay = now.day;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(titleText, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const Spacer(),
              Text(
                "$current/$goal",
                style: TextStyle(color: cs.primary, fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.edit, size: 18, color: cs.onSurfaceVariant.withValues(alpha: 0.85)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final d = days[i];
                final isActive = d == activeDay;

                if (isActive) {
                  return Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    child: Text("$d", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  );
                }

                return Center(
                  child: Text(
                    "$d",
                    style: TextStyle(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: onAvatarTap,
                borderRadius: BorderRadius.circular(999),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: _NetImage(
                    url: avatarUrl,
                    width: 44,
                    height: 44,
                    radius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  greetText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w900, fontSize: 16, height: 1.2),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                    foregroundColor: const Color(0xFF0B66FF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.25)),
                  ),
                  onPressed: onGas,
                  child: Text(gasText, style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChallengeHeroCard extends StatelessWidget {
  final String daysBadge;
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onStart;
  final VoidCallback onTapCard;

  final String startText;

  const _ChallengeHeroCard({
    required this.daysBadge,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onStart,
    required this.onTapCard,
    this.startText = "MULAI",
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapCard,
      borderRadius: BorderRadius.circular(26),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: _NetImage(url: imageUrl),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              top: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: Text(daysBadge, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26, height: 1.0),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0B66FF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      onPressed: onStart,
                      child: Text(startText, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _FocusCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 108,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: cs.primary.withValues(alpha: 0.95)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.75), fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCategoryCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _AddCategoryCard({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(Icons.add, color: cs.onSurfaceVariant.withValues(alpha: 0.9)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w900, fontSize: 16, height: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================
// BOTTOM SHEETS
// =======================

class _TimerChooserSheet extends StatelessWidget {
  const _TimerChooserSheet();

  @override
  Widget build(BuildContext context) {
    final isEn = appState.language == "English";
    String t(String id, String en) => isEn ? en : id;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t("Pilih Mode Timer", "Choose Timer Mode"),
              style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(t("Pilih timer latihan atau timer jogging.", "Pick workout timer or jogging timer.")),
          const SizedBox(height: 12),

          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.hourglass_bottom_rounded),
                  title: Text(t("Timer Latihan (Countdown)", "Workout Timer (Countdown)"),
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(t("Hitung mundur sesuai menit.", "Counts down by minutes.")),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(context, "countdown"),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.directions_run_rounded),
                  title: Text(t("Timer Jogging (Stopwatch)", "Jogging Timer (Stopwatch)"),
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(t("Hitung naik dari 00:00.", "Counts up from 00:00.")),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(context, "stopwatch"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyGoalSheet extends StatefulWidget {
  final String title;
  final int current;

  const _WeeklyGoalSheet({required this.title, required this.current});

  @override
  State<_WeeklyGoalSheet> createState() => _WeeklyGoalSheetState();
}

class _WeeklyGoalSheetState extends State<_WeeklyGoalSheet> {
  late int selected = widget.current;

  @override
  Widget build(BuildContext context) {
    final isEn = appState.language == "English";
    String t(String id, String en) => isEn ? en : id;

    final options = [1, 2, 3, 4, 5, 6, 7];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(t("Pilih target latihan per minggu", "Choose workouts per week")),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((n) {
              final active = n == selected;
              return ChoiceChip(
                label: Text(
                  "$n",
                  style: TextStyle(fontWeight: FontWeight.w900, color: active ? Colors.white : null),
                ),
                selected: active,
                selectedColor: const Color(0xFF0B66FF),
                onSelected: (_) => setState(() => selected = n),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B66FF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.pop(context, selected),
              child: Text(t("SIMPAN", "SAVE"), style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPickerSheet extends StatelessWidget {
  const _AvatarPickerSheet();

  // ✅ anime style (DiceBear Adventurer)
  static const List<String> _avatars = [
    "https://api.dicebear.com/7.x/adventurer/png?seed=Itadori&size=128",
    "https://api.dicebear.com/7.x/adventurer/png?seed=Gojo&size=128",
    "https://api.dicebear.com/7.x/adventurer/png?seed=Naruto&size=128",
    "https://api.dicebear.com/7.x/adventurer/png?seed=Sasuke&size=128",
    "https://api.dicebear.com/7.x/adventurer/png?seed=Luffy&size=128",
    "https://api.dicebear.com/7.x/adventurer/png?seed=Zoro&size=128",
    "https://api.dicebear.com/7.x/adventurer/png?seed=Goku&size=128",
    "https://api.dicebear.com/7.x/adventurer/png?seed=Levi&size=128",
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEn = appState.language == "English";
    String t(String id, String en) => isEn ? en : id;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t("Pilih Avatar", "Choose Avatar"), style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(t("Tap untuk ganti foto profil.", "Tap to change profile photo.")),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _avatars.map((url) {
                final selected = url == appState.avatarUrl;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () => Navigator.pop(context, url),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? const Color(0xFF0B66FF) : cs.outlineVariant.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Image.network(
                          url,
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 54,
                            height: 54,
                            color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
                            alignment: Alignment.center,
                            child: Icon(Icons.person, color: cs.onSurfaceVariant.withValues(alpha: 0.85)),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySheet extends StatelessWidget {
  final String title;
  final List<String> items;

  const _CategorySheet({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: items.map((it) {
                final isLast = it == items.last;
                return Column(
                  children: [
                    ListTile(
                      title: Text(it, style: const TextStyle(fontWeight: FontWeight.w900)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pop(context, it),
                    ),
                    if (!isLast) const Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickMinuteSheet extends StatefulWidget {
  const _QuickMinuteSheet();

  @override
  State<_QuickMinuteSheet> createState() => _QuickMinuteSheetState();
}

class _QuickMinuteSheetState extends State<_QuickMinuteSheet> {
  int selected = 1;

  @override
  Widget build(BuildContext context) {
    final options = [1, 2, 3, 5, 10, 15, 20, 30];

    final isEn = appState.language == "English";
    String t(String id, String en) => isEn ? en : id;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t("Timer Cepat", "Quick Timer"), style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(t("Pilih durasi mulai dari 1 menit", "Choose duration starting from 1 minute")),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((m) {
              final active = m == selected;
              return ChoiceChip(
                label: Text(
                  isEn ? "$m min" : "$m menit",
                  style: TextStyle(fontWeight: FontWeight.w900, color: active ? Colors.white : null),
                ),
                selected: active,
                selectedColor: const Color(0xFF0B66FF),
                onSelected: (_) => setState(() => selected = m),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B66FF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.pop(context, selected),
              child: Text(t("MULAI", "START"), style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}
