import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'sign_in_state.dart';

class SignInNotifier extends StateNotifier<SignInState> {
  SignInNotifier() : super(const SignInState.initial());

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithEmail(String email, String password) async {
    state = const SignInState.loading();
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      state = SignInState.success(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error (Sign Up): Code: ${e.code} - Message: ${e.message}');  // Agrega este print para debug en terminal
      state = SignInState.error(e.message ?? 'Error al registrar');
    } catch (e) {
      print('Unknown Error (Sign Up): $e');  // Debug
      state = SignInState.error('Error desconocido');
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    state = const SignInState.loading();
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      state = SignInState.success(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error (Login): Code: ${e.code} - Message: ${e.message}');  // Agrega este print
      state = SignInState.error(e.message ?? 'Error al iniciar sesión');
    } catch (e) {
      print('Unknown Error (Login): $e');  // Debug
      state = SignInState.error('Error desconocido');
    }
  }
}