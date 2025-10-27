import 'package:dartz/dartz.dart';
import 'package:flutter_template/core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';


class CheckAuthStatusUseCase {
  final AuthRepository repository;
  const CheckAuthStatusUseCase(this.repository);

  Stream<Either<Failure, User?>> call() {
    return repository.authStateChanges;
  }
}