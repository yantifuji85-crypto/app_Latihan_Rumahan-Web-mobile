class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _dict = {
    "id": {
      "report": "Laporan",
      "history": "Riwayat",
      "all_logs": "Semua catatan",
      "body_weight": "Berat Badan",
      "log": "Catat",
      "chart": "Grafik",
      "workouts": "latihan",
      "min": "menit",
      "start": "Mulai",
      "no_history": "Belum ada riwayat latihan.\nCoba mulai latihan dulu.",
      "no_weight": "Belum ada data berat badan.\nKlik “Catat” buat mulai.",
      "showing_14": "Tampil maksimal 14 catatan terakhir",
    },
    "en": {
      "report": "Report",
      "history": "History",
      "all_logs": "All logs",
      "body_weight": "Body Weight",
      "log": "Log",
      "chart": "Chart",
      "workouts": "workouts",
      "min": "min",
      "start": "Start",
      "no_history": "No workout history yet.\nStart a workout first.",
      "no_weight": "No weight data yet.\nTap “Log” to start.",
      "showing_14": "Showing up to last 14 entries",
    },
  };

  /// ✅ TIDAK PERNAH return null
  static String t({
    required String language, // "English" / lainnya
    required String key,
    String? fallback,
  }) {
    final langKey = (language == "English") ? "en" : "id";
    return _dict[langKey]?[key] ?? fallback ?? key;
  }
}
