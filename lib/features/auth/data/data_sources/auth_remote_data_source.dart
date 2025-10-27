import 'package:firebase_auth/firebase_auth.dart' as fb_auth;


abstract class AuthRemoteDataSource {
  // Returns the native Firebase User object stream (nullable)
  Stream<fb_auth.User?> get authStateChanges;

  // Throws FirebaseAuthException on failure, returns UserCredential on success.
  Future<fb_auth.UserCredential> signUp({required String email, required String password});

  // Throws FirebaseAuthException on failure, returns UserCredential on success.
  Future<fb_auth.UserCredential> signIn({required String email, required String password});

  // Throws FirebaseAuthException on failure (or generic Exception)
  Future<void> signOut();
}
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb_auth.FirebaseAuth firebaseAuth;

  // FIX 1: Added semicolon (;) to the constructor.
  const AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<fb_auth.UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    // Note: No try-catch here! Let the exception propagate to the Repository.
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Returns the Firebase object
    return userCredential;
  }

  @override
  Future<fb_auth.UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final userCredential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  @override
  Stream<fb_auth.User?> get authStateChanges {
    return firebaseAuth.authStateChanges();
  }
}