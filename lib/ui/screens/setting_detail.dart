import 'package:flutter/material.dart';

class SettingDetailScreen extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SettingDetailScreen({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              subtitle ?? "Halaman pengaturan untuk \"$title\" (placeholder).",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
