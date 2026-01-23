import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:email_validator/email_validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  bool _loading = false;
  bool _hidePass = true;

  late final AnimationController _ctl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  late final Animation<double> _fade =
  CurvedAnimation(parent: _ctl, curve: Curves.easeOutCubic);

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ctl, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _ctl.forward();
  }

  @override
  void dispose() {
    _ctl.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _loginEmail() async {
    if (_loading) return;

    final email = _email.text.trim();
    final pass = _pass.text;

    if (email.isEmpty || pass.isEmpty) {
      _snack("Email & password wajib diisi.");
      return;
    }

    if (!EmailValidator.validate(email)) {
      _snack("Format email tidak valid.");
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      // ✅ AuthGate akan otomatis pindah kalau sukses
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'user-not-found' => 'User tidak ditemukan. (Belum daftar?)',
        'wrong-password' => 'Password salah.',
        'invalid-email' => 'Format email tidak valid.',
        'invalid-credential' => 'Email atau password salah.',
        'too-many-requests' => 'Terlalu banyak percobaan. Coba lagi nanti.',
        'network-request-failed' => 'Tidak ada koneksi internet.',
        'user-disabled' => 'Akun dinonaktifkan.',
        _ => 'Auth error: ${e.code}',
      };
      _snack(msg);
    } catch (e) {
      _snack("Gagal: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginGoogle() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      // ✅ plugin google_sign_in 7.x: initialize + authenticate
      await GoogleSignIn.instance.initialize();

      final GoogleSignInAccount? googleUser =
      await GoogleSignIn.instance.authenticate();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // ✅ FIX: google_sign_in 7.x udah gak expose accessToken
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      _snack("Google Sign-In error: ${e.code}");
    } on FirebaseAuthException catch (e) {
      _snack("FirebaseAuth error: ${e.code}");
    } catch (e) {
      _snack("Login Google gagal: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF071018),
                  Color(0xFF0B1220),
                  Color(0xFF111827),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: 270,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=1400&q=80",
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.white.withOpacity(0.06)),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.10),
                            Colors.black.withOpacity(0.62),
                            const Color(0xFF071018),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: FadeTransition(
                        opacity: _fade,
                        child: SlideTransition(
                          position: _slide,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(26),
                                child: BackdropFilter(
                                  filter:
                                  ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        18, 18, 18, 18),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(26),
                                      border: Border.all(
                                          color: Colors.white.withOpacity(0.14)),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 26,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 14),
                                          color: Colors.black.withOpacity(0.35),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: const [
                                            _BarbellBadge(),
                                            SizedBox(width: 10),
                                            Text(
                                              "Bodyweight Workout",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 14.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Masuk",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 22,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Masukkan email & password, atau lanjut dengan Google.",
                                            style: TextStyle(
                                              color:
                                              Colors.white.withOpacity(0.70),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        _Field(
                                          controller: _email,
                                          hint: "Email",
                                          icon: Icons.mail_rounded,
                                          keyboardType: TextInputType.emailAddress,
                                        ),
                                        const SizedBox(height: 10),
                                        _Field(
                                          controller: _pass,
                                          hint: "Password",
                                          icon: Icons.lock_rounded,
                                          obscureText: _hidePass,
                                          suffix: IconButton(
                                            onPressed: () => setState(
                                                    () => _hidePass = !_hidePass),
                                            icon: Icon(
                                              _hidePass
                                                  ? Icons.visibility_rounded
                                                  : Icons.visibility_off_rounded,
                                              color:
                                              Colors.white.withOpacity(0.75),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 48,
                                          child: ElevatedButton(
                                            onPressed: _loading ? null : _loginEmail,
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              backgroundColor:
                                              const Color(0xFF22C55E),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(14),
                                              ),
                                            ),
                                            child: _loading
                                                ? const SizedBox(
                                              height: 22,
                                              width: 22,
                                              child:
                                              CircularProgressIndicator(
                                                strokeWidth: 2.6,
                                                color: Colors.white,
                                              ),
                                            )
                                                : const Text(
                                              "LOGIN EMAIL",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextButton(
                                              onPressed: _loading
                                                  ? null
                                                  : () => _snack(
                                                  "Nanti: halaman register"),
                                              child: Text(
                                                "Buat akun",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.78),
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: _loading
                                                  ? null
                                                  : () => _snack(
                                                  "Nanti: lupa password"),
                                              child: Text(
                                                "Lupa password?",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.78),
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Divider(
                                                color: Colors.white
                                                    .withOpacity(0.16),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              child: Text(
                                                "OR",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.60),
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Divider(
                                                color: Colors.white
                                                    .withOpacity(0.16),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 48,
                                          child: ElevatedButton(
                                            onPressed: _loading ? null : _loginGoogle,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: Colors.black87,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(14),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 22,
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(6),
                                                    color: Colors.black
                                                        .withOpacity(0.06),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "G",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w900,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                const Text(
                                                  "Continue with Google",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 14.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "Dengan login, kamu setuju dengan kebijakan aplikasi.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: cs.onSurface.withOpacity(0.45),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BarbellBadge extends StatelessWidget {
  const _BarbellBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF22C55E),
            Color(0xFF60A5FA),
          ],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.25),
          ),
        ],
      ),
      child: const Icon(
        Icons.fitness_center_rounded,
        size: 18,
        color: Colors.white,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.75)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.30)),
        ),
      ),
    );
  }
}
