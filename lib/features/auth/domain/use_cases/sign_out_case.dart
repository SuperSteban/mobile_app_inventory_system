import 'package:dartz/dartz.dart';
import 'package:mobile_app_inventory_system/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository authRepository;
  const SignOutUseCase(this.authRepository);


  Future<void> call() {
    return authRepository.signOut();
  }
}