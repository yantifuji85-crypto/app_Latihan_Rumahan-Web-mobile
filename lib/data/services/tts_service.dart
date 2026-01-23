import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._();
  static final TtsService I = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;
    _inited = true;

    // Biar lebih stabil di beberapa device
    try {
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {}

    // Konfigurasi dasar (suara lebih "berat" -> pitch dikurangin)
    try {
      await _tts.setVolume(1.0);
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(0.88); // ✅ lebih cowo daripada 1.0
    } catch (_) {}

    // Pilih bahasa Indonesia (fallback kalau gak tersedia)
    String lang = "en-US";
    try {
      final langs = await _tts.getLanguages;
      final s = langs.toString();
      final hasId = s.contains("id-ID") || s.contains("id_ID");
      lang = hasId ? "id-ID" : "en-US";
      await _tts.setLanguage(lang);
    } catch (_) {
      try {
        lang = "en-US";
        await _tts.setLanguage(lang);
      } catch (_) {}
    }

    // ✅ Paksa pilih VOICE cowo kalau ada
    try {
      final voices = await _tts.getVoices;
      if (voices is List) {
        Map<dynamic, dynamic>? pick;

        // helper: cek apakah voice cocok bahasa yang dipilih
        bool matchLang(Map v) {
          final vLocale = (v['locale'] ?? v['language'] ?? '').toString();
          if (vLocale.isEmpty) return false;
          // contoh locale: "id-ID", "en-US"
          return vLocale.toLowerCase().contains(lang.toLowerCase().substring(0, 2));
        }

        // 1) cari male/man (paling prioritas)
        for (final it in voices) {
          if (it is! Map) continue;
          final name = (it['name'] ?? '').toString().toLowerCase();
          final gender = (it['gender'] ?? '').toString().toLowerCase();
          if (matchLang(it) && (name.contains("male") || name.contains("man") || gender.contains("male"))) {
            pick = it.cast<dynamic, dynamic>();
            break;
          }
        }

        // 2) kalau gak ada, cari voice yang cocok bahasa aja
        pick ??= voices.cast<dynamic>().whereType<Map>().cast<Map>().firstWhere(
              (v) => matchLang(v),
          orElse: () => <dynamic, dynamic>{},
        );

        if (pick.isNotEmpty) {
          await _tts.setVoice({
            "name": pick["name"],
            "locale": pick["locale"] ?? pick["language"],
          });
        }
      }
    } catch (_) {}

    if (kDebugMode) {
      // ignore: avoid_print
      print("TTS inited (lang=$lang)");
      try {
        final engines = await _tts.getEngines;
        // ignore: avoid_print
        print("TTS engines: $engines");
      } catch (_) {}
    }
  }

  /// flush=true  -> stop dulu (buat START/FINISH biar jelas)
  /// flush=false -> queue (buat hitungan 10..1 biar berurutan)
  Future<void> speak(String text, {bool flush = true}) async {
    final t = text.trim();
    if (t.isEmpty) return;

    await init();

    try {
      if (flush) {
        await _tts.stop();
      }
    } catch (_) {}

    if (kDebugMode) {
      // ignore: avoid_print
      print("TTS speak(flush=$flush): $t");
    }

    try {
      await _tts.speak(t);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print("TTS speak error: $e");
      }
    }
  }

  Future<void> stop() async {
    await init();
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
