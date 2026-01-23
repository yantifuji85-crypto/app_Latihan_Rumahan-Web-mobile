import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ✅ share + open link
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import 'feedback.dart';
import 'settings_general.dart';
import 'settings_language.dart';
import 'settings_tts.dart';
import 'settings_workout.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool get _en => appState.language == "English";
  String _t(String id, String en) => _en ? en : id;

  // =======================
  // ✅ PLACEHOLDER (AMAN)
  // =======================
  static const String kWhatsAppNumber = "6281234567890"; // ganti kalau mau (tanpa +)
  static const String kGoogleFormUrl = "https://forms.gle/REPLACE_ME"; // dummy
  static const String kSupportEmail = "support@latihanrumahan.com"; // dummy
  static const String kPlayStoreUrl = "https://play.google.com/store"; // app belum rilis -> umum dulu

  String _languageLabel(String raw) {
    if (raw == "English") return "English";
    if (raw == "Indonesia") return _en ? "Indonesian" : "Indonesia";
    return _en ? "Default" : "Default";
  }

  void _push(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _snack(String msg) {
    final m = ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    m.showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) _snack(_t("Gagal membuka link.", "Failed to open link."));
  }

  String _waLink(String message) {
    final encoded = Uri.encodeComponent(message);
    return "https://wa.me/$kWhatsAppNumber?text=$encoded";
  }

  String _mailToLink({
    required String to,
    required String subject,
    required String body,
  }) {
    final s = Uri.encodeComponent(subject);
    final b = Uri.encodeComponent(body);
    return "mailto:$to?subject=$s&body=$b";
  }

  Future<void> _share() async {
    final text = _t(
      "Aku baru selesai latihan di Latihan Rumahan 💪\n"
          "Ringkasan hari ini: ${appState.totalWorkout} latihan • ${appState.totalMinutes} menit • ${appState.totalKcal} kkal",
      "I just finished a workout on Latihan Rumahan 💪\n"
          "Today’s summary: ${appState.totalWorkout} workouts • ${appState.totalMinutes} min • ${appState.totalKcal} kcal",
    );

    await Share.share(text);
  }

  Future<void> _suggestFeature() async {
    final cs = Theme.of(context).colorScheme;

    final title = _t("Kirim Usulan", "Send a Suggestion");

    final template = _t(
      "Halo Tim Latihan Rumahan,\n\n"
          "Saya ingin mengusulkan fitur berikut:\n"
          "• (tulis usulan kamu)\n\n"
          "Detail tambahan (opsional):\n"
          "• Perangkat: Android/iOS\n"
          "• Versi aplikasi: 1.6.39\n\n"
          "Terima kasih.",
      "Hello Latihan Rumahan Team,\n\n"
          "I’d like to suggest this feature:\n"
          "• (write your suggestion)\n\n"
          "Extra details (optional):\n"
          "• Device: Android/iOS\n"
          "• App version: 1.6.39\n\n"
          "Thank you.",
    );

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.chat_bubble_rounded, color: cs.primary),
                      title: Text(_t("WhatsApp", "WhatsApp"), style: const TextStyle(fontWeight: FontWeight.w900)),
                      subtitle: Text(
                        _t("Chat cepat ke admin", "Quick chat to support"),
                        style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        Navigator.pop(context);
                        await _openUrl(_waLink(template));
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.description_outlined, color: cs.primary),
                      title: Text(_t("Google Form", "Google Form"), style: const TextStyle(fontWeight: FontWeight.w900)),
                      subtitle: Text(
                        _t("Isi form usulan", "Fill the suggestion form"),
                        style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        Navigator.pop(context);
                        await _openUrl(kGoogleFormUrl);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.email_outlined, color: cs.primary),
                      title: Text(_t("Email", "Email"), style: const TextStyle(fontWeight: FontWeight.w900)),
                      subtitle: Text(
                        kSupportEmail,
                        style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        Navigator.pop(context);
                        await _openUrl(
                          _mailToLink(
                            to: kSupportEmail,
                            subject: _t("Usulan fitur - Latihan Rumahan", "Feature suggestion - Latihan Rumahan"),
                            body: template,
                          ),
                        );
                      },
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

  Future<void> _logout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _snack(_t("Kamu belum login.", "You are not logged in."));
      return;
    }

    try {
      await FirebaseAuth.instance.signOut();

      await GoogleSignIn.instance.signOut();
      try {
        await GoogleSignIn.instance.disconnect();
      } catch (_) {}

      _snack(_t("Berhasil logout.", "Logged out successfully."));
    } catch (e) {
      _snack(_t("Gagal logout: $e", "Logout failed: $e"));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: appState,
      builder: (_, __) {
        final isLoggedIn = FirebaseAuth.instance.currentUser != null;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              Text(
                _t("PENGATURAN", "SETTINGS"),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),

              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _SettingRow(
                      color: const Color(0xFF22C55E),
                      icon: Icons.fitness_center,
                      title: _t("Pengaturan latihan", "Workout settings"),
                      onTap: () => _push(const SettingsWorkoutScreen()),
                    ),
                    const Divider(height: 1),
                    _SettingRow(
                      color: const Color(0xFF0EA5E9),
                      icon: Icons.settings,
                      title: _t("Setelan umum", "General settings"),
                      onTap: () => _push(const SettingsGeneralScreen()),
                    ),
                    const Divider(height: 1),
                    _SettingRow(
                      color: const Color(0xFFF59E0B),
                      icon: Icons.mic,
                      title: _t("Opsi Suara (TTS)", "Voice options (TTS)"),
                      onTap: () => _push(const SettingsTtsScreen()),
                    ),
                    const Divider(height: 1),

                    _SettingRow(
                      color: const Color(0xFF06B6D4),
                      icon: Icons.chat_bubble_outline,
                      title: _t("Usulkan Fitur Lainnya", "Suggest other features"),
                      onTap: _suggestFeature,
                    ),
                    const Divider(height: 1),

                    _SettingRow(
                      color: const Color(0xFF7C3AED),
                      icon: Icons.language,
                      title: _t("Opsi bahasa", "Language"),
                      subtitle: _languageLabel(appState.language),
                      onTap: () => _push(const SettingsLanguageScreen()),
                    ),
                    const Divider(height: 1),

                    // ✅ sekarang toggle disimpan ke AppState
                    _SwitchSettingRow(
                      color: cs.surfaceContainerHighest,
                      icon: Icons.link,
                      title: _t("Sinkronisasi dengan Health Connect", "Sync with Health"),
                      subtitle: _t("Simpan latihan ke Health Connect/HealthKit", "Save workouts to Health Connect/HealthKit"),
                      value: appState.healthConnect,
                      onChanged: (v) {
                        appState.setHealthConnect(v);
                        _snack(_t(
                          v
                              ? "Sinkronisasi Health diaktifkan. Saat latihan selesai, data akan dikirim ke Health."
                              : "Sinkronisasi Health dimatikan.",
                          v
                              ? "Health sync enabled. When a workout ends, data will be sent to Health."
                              : "Health sync disabled.",
                        ));
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _SettingRow(
                      color: const Color(0xFF64748B),
                      icon: Icons.share,
                      title: _t("Berbagi dengan teman", "Share with friends"),
                      onTap: _share,
                      iconWhite: true,
                    ),
                    const Divider(height: 1),

                    _SettingRow(
                      color: const Color(0xFF64748B),
                      icon: Icons.star,
                      title: _t("Beri kami nilai", "Rate us"),
                      onTap: () async => _openUrl(kPlayStoreUrl),
                      iconWhite: true,
                    ),
                    const Divider(height: 1),

                    _SettingRow(
                      color: const Color(0xFF64748B),
                      icon: Icons.edit,
                      title: _t("Masukan", "Feedback"),
                      onTap: () => _push(const FeedbackScreen()),
                      iconWhite: true,
                    ),
                    const Divider(height: 1),

                    _SettingRow(
                      color: const Color(0xFFEF4444),
                      icon: Icons.logout_rounded,
                      title: _t("Logout", "Logout"),
                      subtitle: isLoggedIn
                          ? _t("Keluar dari akun saat ini", "Sign out from current account")
                          : _t("Belum login", "Not logged in"),
                      onTap: () {
                        if (!isLoggedIn) {
                          _snack(_t("Kamu belum login.", "You are not logged in."));
                          return;
                        }
                        _logout();
                      },
                      iconWhite: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              Center(
                child: Text(
                  _t("Version 1.6.39", "Version 1.6.39"),
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingRow extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool iconWhite;

  const _SettingRow({
    required this.color,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconWhite = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: subtitle == null
          ? null
          : Text(
        subtitle!,
        style: TextStyle(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _SwitchSettingRow extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchSettingRow({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: cs.onSurfaceVariant),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}
