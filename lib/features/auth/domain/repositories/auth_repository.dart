import 'package:mobile_app_inventory_system/features/auth/domain/entities/user.dart';
import 'package:dartz/dartz.dart';
import 'package:mobile_app_inventory_system/core/error/failures.dart';

abstract class AuthRepository {
  // Retorna un Stream si el usurio Esta Authenticado
  Stream<Either<Failure, UserEntity?>> get authStateChange;

  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
  });

  // Retorna void o solo Failure
  Future<Either<Failure, void>> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

}