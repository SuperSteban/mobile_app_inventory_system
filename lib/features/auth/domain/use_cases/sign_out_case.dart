import 'package:dartz/dartz.dart';
import 'package:mobile_app_inventory_system/features/auth/domain/repositories/auth_repository.dart';

import '../../../../core/error/failures.dart';

class SignOutUseCase {
  final AuthRepository authRepository;
  const SignOutUseCase(this.authRepository);


  Future<Either<Failure, Unit>>? call() {
    return authRepository.signOut();
  }
}