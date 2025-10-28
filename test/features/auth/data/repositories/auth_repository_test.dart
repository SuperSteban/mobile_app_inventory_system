// test/features/auth/data/repositories/auth_repository_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_inventory_system/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:mobile_app_inventory_system/features/auth/data/repositories/auth_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_inventory_system/core/error/failures.dart';

@GenerateMocks([
  AuthRemoteDataSource,
  UserCredential,
  User
])
import 'auth_repository_test.mocks.dart'; // Archivo generado

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource: mockDataSource);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUid = 'test-uid-123';
  final MockUser mockFirebaseUser = MockUser();
  when(mockFirebaseUser.uid).thenReturn(tUid);
  when(mockFirebaseUser.email).thenReturn(tEmail);
  when(mockFirebaseUser.displayName).thenReturn('Test User'); // Opcional
  final MockUserCredential mockUserCredential = MockUserCredential();
  when(mockUserCredential.user).thenReturn(mockFirebaseUser);

  group('Sign In', () {

    test('debe devolver Right(unit) cuando el Data Source es exitoso', () async {
      when(mockDataSource.signIn(email: tEmail, password: tPassword))
          .thenAnswer((_) async => mockUserCredential);
      final result = await repository.signIn(email: tEmail, password: tPassword);
      expect(result, const Right(unit));
      verify(mockDataSource.signIn(email: tEmail, password: tPassword)).called(1);
      verifyNoMoreInteractions(mockDataSource);
    });

    test('debe devolver Left(InvalidCredentialsFailure) cuando Firebase lanza wrong-password', () async {
      // ARRANGE: Simula el error específico de Firebase.
      when(mockDataSource.signIn(email: tEmail, password: tPassword))
          .thenThrow(FirebaseAuthException(code: 'wrong-password', message: 'Contraseña incorrecta'));

      final result = await repository.signIn(email: tEmail, password: tPassword);

      expect(result.isLeft(), true);
      result.fold(
            (failure) => expect(failure, isA<InvalidCredentialsFailure>()),
            (r) => fail('Se esperaba un fallo, pero se obtuvo éxito.'),
      );
      verify(mockDataSource.signIn(email: tEmail, password: tPassword)).called(1);
    });

    test('debe devolver Left(ServerFailure) para excepciones desconocidas', () async {
      // ARRANGE: Simula una excepción genérica.
      when(mockDataSource.signIn(email: tEmail, password: tPassword))
          .thenThrow(Exception('Error de conexión.'));

      final result = await repository.signIn(email: tEmail, password: tPassword);

      // CORRECCIÓN CLAVE: Verifica que el resultado es Left y que el fallo es el tipo genérico.
      expect(result.isLeft(), true);
      result.fold(
            (failure) => expect(failure, isA<ServerFailure>()),
            (r) => fail('Se esperaba un fallo, pero se obtuvo éxito.'),
      );
      verify(mockDataSource.signIn(email: tEmail, password: tPassword)).called(1);
    });
  });
}