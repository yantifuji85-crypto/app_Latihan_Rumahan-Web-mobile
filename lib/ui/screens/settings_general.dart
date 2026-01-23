import 'package:flutter/material.dart';
import '../../main.dart';
import '../../data/services/local_notif_service.dart';

class SettingsGeneralScreen extends StatelessWidget {
  const SettingsGeneralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    void snack(String msg) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }

    return AnimatedBuilder(
      animation: appState,
      builder: (_, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Setelan umum",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: appState.darkMode,
                      onChanged: appState.setDarkMode,
                      title: const Text(
                        "Mode Gelap",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: const Text("Ubah tema aplikasi"),
                    ),
                    const Divider(height: 1),

                    // ✅ NOTIFIKASI BENERAN
                    SwitchListTile(
                      value: appState.notifications,
                      onChanged: (v) async {
                        // kalau user nyalain
                        if (v) {
                          try {
                            final ok = await LocalNotifService.I.requestPermissionIfNeeded();

                            // kalau ditolak: balikin switch ke OFF
                            if (!ok) {
                              appState.setNotifications(false);
                              snack("Izin notifikasi ditolak.");
                              return;
                            }

                            // update state ON
                            appState.setNotifications(true);

                            // notif test biar langsung keliatan
                            await LocalNotifService.I.showTest();

                            // jadwalin reminder harian (simple)
                            await LocalNotifService.I.scheduleDailySimple();

                            snack("Notifikasi aktif ✅ (akan ngingetin tiap hari)");
                          } catch (e) {
                            // kalau error: balikin OFF biar konsisten
                            appState.setNotifications(false);
                            snack("Gagal aktifkan notifikasi: $e");
                          }
                        } else {
                          // kalau user matiin
                          try {
                            appState.setNotifications(false);
                            await LocalNotifService.I.cancelAll();
                            snack("Notifikasi dimatikan.");
                          } catch (e) {
                            snack("Gagal matikan notifikasi: $e");
                          }
                        }
                      },
                      title: const Text(
                        "Notifikasi",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        appState.notifications ? "Aktif" : "Nonaktif",
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
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
