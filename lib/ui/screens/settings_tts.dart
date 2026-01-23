import 'package:flutter/material.dart';
import '../../main.dart';

class SettingsTtsScreen extends StatelessWidget {
  const SettingsTtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (_, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Opsi Suara (TTS)", style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: appState.tts,
                      onChanged: appState.setTts,
                      title: const Text("Aktifkan TTS", style: TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: const Text("Suara instruksi saat latihan"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
