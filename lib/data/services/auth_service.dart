import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  Future<void> signInWithGoogle() async {
    // ✅ v7: init dulu
    await GoogleSignIn.instance.initialize();

    // ✅ v7: authenticate (bukan signIn)
    final GoogleSignInAccount? googleUser =
    await GoogleSignIn.instance.authenticate();
    if (googleUser == null) return; // user cancel

    // ✅ ambil token (WAJIB await)
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await FirebaseAuth.instance.signOut();
  }
}
