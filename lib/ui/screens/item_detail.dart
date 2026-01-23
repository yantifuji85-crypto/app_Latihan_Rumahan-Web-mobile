import 'package:flutter/material.dart';
import 'timer_mode.dart';

class ItemDetailScreen extends StatelessWidget {
  final String section;
  final String title;
  final String subtitle;
  final String imageUrl;
  final int defaultMinutes;

  const ItemDetailScreen({
    super.key,
    required this.section,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.defaultMinutes = 6,
  });

  Future<int?> _pickMinutes(BuildContext context) async {
    final options = [1, 2, 3, 5, 6, 10, 15, 20, 30];
    int selected = defaultMinutes < 1 ? 1 : defaultMinutes;

    return showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pilih durasi", style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: options.map((m) {
                      final active = m == selected;
                      return ChoiceChip(
                        label: Text("$m menit", style: TextStyle(fontWeight: FontWeight.w900, color: active ? Colors.white : null)),
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
                      child: const Text("MULAI", style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
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
                  Container(color: Colors.black.withOpacity(0.25)),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 18,
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Rencana singkat", style: TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _ChipInfo(icon: Icons.timer, text: "Mulai 1 menit+"),
                              _ChipInfo(icon: Icons.local_fire_department, text: "Estimasi kcal"),
                              _ChipInfo(icon: Icons.bar_chart, text: "Pemula"),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Klik MULAI untuk pilih durasi timer.",
                            style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B66FF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              onPressed: () async {
                final minutes = await _pickMinutes(context);
                if (minutes == null) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TimerModeScreen(title: title, totalMinutes: minutes),
                  ),
                );
              },
              child: const Text("MULAI", style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ChipInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
