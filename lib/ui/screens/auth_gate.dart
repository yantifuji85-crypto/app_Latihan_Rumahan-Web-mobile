import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart'; // sesuaikan path kalau beda
import '../root_shell.dart'; // atau pakai Navigator pushReplacementNamed

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snap.data;

        // ✅ sudah login -> masuk root app
        if (user != null) {
          return const RootShell();
          // atau: return const HomeScreen(); kalau app lo bukan RootShell
        }

        // ❌ belum login -> login screen
        return const LoginScreen();
      },
    );
  }
}
