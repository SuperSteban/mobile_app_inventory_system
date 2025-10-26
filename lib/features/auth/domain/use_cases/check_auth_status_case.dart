import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository repository;
  const CheckAuthStatusUseCase(this.repository);

  Stream<Either<Failure, User?>> call() {
    return repository.authStateChanges;
  }
}