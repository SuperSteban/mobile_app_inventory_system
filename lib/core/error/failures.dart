import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure([this.message = 'Ocurrió un error inesperado.']);

  @override
  List<Object> get props => [message];
}

abstract class AuthFailure extends Failure {
  const AuthFailure([super.message = '']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error de comunicación con el servidor.']);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([
    super.message = "Credenciales inválidas. Verifica tu correo y contraseña."
  ]);
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure([
    super.message = "El usuario no existe."
  ]);
}

class SignOutFailure extends AuthFailure {
  const SignOutFailure([
    super.message = "No es posible cerrar sesión. Inténtelo más tarde."
  ]);
}

class NeedRecentLoginFailure extends AuthFailure {
  const NeedRecentLoginFailure([
    super.message = "Se necesita, volver iniciar session."
  ]);
}