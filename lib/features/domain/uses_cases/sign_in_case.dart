import 'package:dartz/dartz.dart';
import 'package:flutter_template/core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SignInParams {
  final String email;
  final String password;
  const SignInParams({required this.email, required this.password})
}
class SignInUseCase {

  final AuthRepository authRepository;
  const SignInUseCase(this.authRepository)

  Future<Either<Failure, void>> call(SignInParams params) {
    return authRepository.signIn(
      email: params.email,
      password: params.password

    );
  }

}