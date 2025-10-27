import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_inventory_system/core/error/failures.dart';
// Asume que este archivo existe con tus fallos específicos

Either<Failure, T> translateFirebaseAuthException<T>(FirebaseAuthException e) {

  // Usamos e.code, que es el string estandarizado de Firebase para errores.
  switch (e.code) {
    case 'invalid-email':
      return Left(const InvalidCredentialsFailure());

    case 'user-not-found':
      return Left(const UserNotFoundFailure());

    case 'wrong-password':
      return Left(const InvalidCredentialsFailure());


    case 'requires-recent-login': // Común en operaciones sensibles
      return Left(const NeedRecentLoginFailure());

    default:
    // Si es un error desconocido, lo reportamos como un Fallo de Servidor genérico.
    // El mensaje se usa para el logging interno.
      return Left(ServerFailure(e.message ?? 'Error de autenticación desconocido.'));
  }
}