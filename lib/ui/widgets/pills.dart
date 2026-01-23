import 'package:flutter/material.dart';

class ProPill extends StatelessWidget {
  final String text;
  const ProPill({super.key, this.text = "PRO"});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE7C2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ ganti Icons.crown -> workspace_premium (pasti ada)
          const Icon(Icons.workspace_premium, size: 14, color: Color(0xFF8A5A00)),
          const SizedBox(width: 6),
          Text(
            "$text↑",
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: Color(0xFF8A5A00),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchPill extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  const SearchPill({super.key, required this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF0F3),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.black38),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
