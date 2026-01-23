import 'package:flutter/material.dart';

// ✅ FIX IMPORT (pilih salah satu):
// import 'package:latihan_rumahan/data/workout_data.dart';
// import 'package:bodyweight_workout/data/workout_data.dart';
import '../../data/workout_data.dart'; // kItems

import 'item_detail.dart';

class SearchScreen extends StatefulWidget {
  // ✅ NEW: buat auto isi keyword & auto tab dari Home
  final String? initialQuery; // misal: "core"
  final String? initialTab; // "semua" | "latihan" | "program" | "tantangan"

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.initialTab,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _c = TextEditingController();

  // tab: semua/latihan/program/tantangan
  String _tab = "semua";

  static const String _fallbackGymImg =
      "https://images.pexels.com/photos/1552106/pexels-photo-1552106.jpeg?auto=compress&cs=tinysrgb&w=1200";

  @override
  void initState() {
    super.initState();

    // ✅ set initial tab kalau dikirim dari Home
    final t = (widget.initialTab ?? "").trim().toLowerCase();
    if (t == "semua" || t == "latihan" || t == "program" || t == "tantangan") {
      _tab = t;
    }

    // ✅ set initial query kalau dikirim dari Home
    final q = (widget.initialQuery ?? "").trim();
    if (q.isNotEmpty) {
      _c.text = q;
      // optional: taruh cursor di akhir biar enak edit
      _c.selection = TextSelection.fromPosition(TextPosition(offset: _c.text.length));
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String _catLabel(String cat) {
    // label kecil di list item (tetap sesuai data)
    return cat; // "latihan", "program", "tantangan"
  }

  Widget _safeNetImage(BuildContext context, String? url, {double? w, double? h}) {
    final cs = Theme.of(context).colorScheme;
    final finalUrl = (url == null || url.trim().isEmpty) ? _fallbackGymImg : url.trim();

    return Image.network(
      finalUrl,
      width: w,
      height: h,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: w,
          height: h,
          color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
          alignment: Alignment.center,
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
          ),
        );
      },
      errorBuilder: (_, __, ___) {
        return Image.network(
          _fallbackGymImg,
          width: w,
          height: h,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              width: w,
              height: h,
              color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
              alignment: Alignment.center,
              child: Icon(
                Icons.fitness_center_rounded,
                color: cs.onSurfaceVariant.withValues(alpha: 0.75),
              ),
            );
          },
        );
      },
    );
  }

  List<WorkoutItem> _filtered() {
    final q = _c.text.trim().toLowerCase();

    // ✅ PENTING: category wajib match sama kItems: latihan/program/tantangan
    Iterable<WorkoutItem> base = kItems;

    if (_tab != "semua") {
      base = base.where((e) => e.category.toLowerCase() == _tab);
    }

    if (q.isNotEmpty) {
      base = base.where((e) {
        final t = e.title.toLowerCase();
        final s = e.subtitle.toLowerCase();
        return t.contains(q) || s.contains(q);
      });
    }

    return base.toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = _filtered();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Pencarian", style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          children: [
            // search box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _c,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: "Cari latihan, program, tantangan...",
                        hintStyle: TextStyle(color: cs.onSurfaceVariant),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: cs.onSurface),
                    ),
                  ),
                  if (_c.text.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        _c.clear();
                        setState(() {});
                      },
                      icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _Chip(
                    text: "Semua",
                    active: _tab == "semua",
                    onTap: () => setState(() => _tab = "semua"),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    text: "Latihan",
                    active: _tab == "latihan",
                    onTap: () => setState(() => _tab = "latihan"),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    text: "Program",
                    active: _tab == "program",
                    onTap: () => setState(() => _tab = "program"),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    text: "Tantangan",
                    active: _tab == "tantangan",
                    onTap: () => setState(() => _tab = "tantangan"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 28),
                child: Center(
                  child: Text(
                    "Tidak ada hasil.",
                    style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w800),
                  ),
                ),
              )
            else
              ...items.map((it) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemDetailScreen(
                            section: it.category.toUpperCase(),
                            title: it.title,
                            subtitle: it.subtitle,
                            imageUrl: it.imageUrl,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.20)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: _safeNetImage(context, it.imageUrl, w: 64, h: 64),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(it.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                                const SizedBox(height: 4),
                                Text(
                                  it.subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "${_catLabel(it.category)} • ${it.defaultMinutes} menit",
                                  style: TextStyle(color: cs.primary, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _Chip({required this.text, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0B66FF) : cs.surfaceContainerHighest.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : cs.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
