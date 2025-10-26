import 'package:flutter/cupertino.dart';

abstract class Failure {
  final String message;
  const Failure([this.message = 'Ocurrió un error inesperado.']);
}

abstract class AuthFailure extends Failure {
  const AuthFailure([super.message]);
}


abstract class ServerFailure extends Failure {}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure({String message = "Credenciales inválidas. Verifica tu correo y contraseña."}): super(message);
}
class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure({String message = "Usuario no existe"}) : super(message);
}