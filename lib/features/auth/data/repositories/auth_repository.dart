import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_inventory_system/core/error/failures.dart';
import 'package:mobile_app_inventory_system/features/auth/data/models/user_model.dart';
import 'package:mobile_app_inventory_system/features/auth/domain/entities/user.dart'; // Asumo que es UserEntity
import 'package:mobile_app_inventory_system/features/auth/domain/repositories/auth_repository.dart';

import '../../../../core/error/firebase_trans_errors.dart';
import '../data_sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, void>> signIn({required String email, required String password}) async {
    try {
      await remoteDataSource.signIn(email: email, password: password);

      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return translateFirebaseAuthException(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({required String email, required String password}) async {
    try {
      final userCredential = await remoteDataSource.signUp(email: email, password: password);

      final userModel = UserModel.fromFirebaseUser(userCredential.user!);

      return Right(userModel.toEntity());
    } on FirebaseAuthException catch (e) {
      return translateFirebaseAuthException(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return translateFirebaseAuthException(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  // TODO: implement authStateState
  Stream<Either<Failure, UserEntity?>> get authStateChange {
    return FirebaseAuth.instance.authStateChanges().map((user) {
      if (user == null) {
        return const Right(null);
      } else {
        final userModel = UserModel.fromFirebaseUser(user);
        return Right(userModel.toEntity());
      }
    });
  }




}