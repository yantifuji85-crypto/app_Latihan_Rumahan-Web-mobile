import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'ui/app/app_state.dart';
import 'ui/app_theme.dart';
import 'ui/screens/auth_gate.dart';
import 'ui/screens/tantangan_detail.dart';
import 'ui/root_shell.dart';

// ✅ TAMBAH INI (route statistik)
import 'ui/screens/stats_screen.dart';

final AppState appState = AppState();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BWApp());
}

class BWApp extends StatelessWidget {
  const BWApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (_, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: appState.darkMode ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),

          // KUNCI (JANGAN DIUBAH)
          home: const AuthGate(),

          routes: {
            '/root': (_) => const RootShell(),
            '/tantangan': (_) => const TantanganDetailScreen(),

            // ✅ ROUTE BARU — STATISTIK
            '/stats': (_) => const StatsScreen(),
          },
        );
      },
    );
  }
}
