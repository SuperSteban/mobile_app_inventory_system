import 'package:equatable/equatable.dart';

// -------------------------------------------------------------------
// 1. CLASE BASE (Failure)
// -------------------------------------------------------------------
abstract class Failure extends Equatable {
  final String message;
  // This constructor defines the positional parameter.
  const Failure([this.message = 'Ocurrió un error inesperado.']);

  @override
  List<Object> get props => [message];
}

// -------------------------------------------------------------------
// 2. FALLOS ABSTRACTOS (Using modern super parameters)
// -------------------------------------------------------------------

abstract class AuthFailure extends Failure {
  // CORRECTED: Using 'super.message' directly. This parameter is automatically
  // passed to the positional argument of the superclass (Failure).
  const AuthFailure([super.message = '']);
}

class ServerFailure extends Failure {
  // This was already perfect.
  const ServerFailure([super.message = 'Error de comunicación con el servidor.']);
}

// -------------------------------------------------------------------
// 3. FALLOS CONCRETOS (CORRECTED)
// -------------------------------------------------------------------

class InvalidCredentialsFailure extends AuthFailure {
  // CORRECTED: Use the modern syntax (super.message) to pass the argument.
  const InvalidCredentialsFailure([
    super.message = "Credenciales inválidas. Verifica tu correo y contraseña."
  ]);
}

class UserNotFoundFailure extends AuthFailure {
  // This was nearly perfect, removed the redundant super(message) call.
  const UserNotFoundFailure([
    super.message = "El usuario no existe."
  ]);
}

class SignOutFailure extends AuthFailure {
  // CORRECTED: Use the modern syntax.
  const SignOutFailure([
    super.message = "No es posible cerrar sesión. Inténtelo más tarde."
  ]);
}

class NeedRecentLoginFailure extends AuthFailure {
  // CORRECTED: Use the modern syntax.
  const NeedRecentLoginFailure([
    super.message = "Se necesita, volver iniciar session."
  ]);
}