import 'package:flutter/material.dart';
import '../../main.dart';

class SettingsLanguageScreen extends StatelessWidget {
  const SettingsLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final options = const ["Indonesia", "English"];

    return AnimatedBuilder(
      animation: appState,
      builder: (_, __) {
        final cs = Theme.of(context).colorScheme;

        // kalau language masih "Default", treat sebagai Indonesia
        final current = (appState.language == "Default") ? "Indonesia" : appState.language;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              current == "English" ? "Select language" : "Opsi bahasa",
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  value: current,
                  items: options
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    appState.setLanguage(v);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          v == "English" ? "Language set: English" : "Bahasa diset: Indonesia",
                        ),
                      ),
                    );
                  },
                  decoration: InputDecoration(
                    labelText: current == "English" ? "Choose language" : "Pilih bahasa",
                    filled: true,
                    fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
