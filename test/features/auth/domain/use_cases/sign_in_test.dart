// test/features/auth/domain/usecases/sign_in_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_inventory_system/features/auth/domain/use_cases/sign_in_case.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:mobile_app_inventory_system/core/error/failures.dart';
import 'package:mobile_app_inventory_system/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_app_inventory_system/features/auth/domain/use_cases/sign_in_case.dart'; // Tu caso de uso

// 1. Generar el Mock de la interfaz de Dominio
@GenerateMocks([AuthRepository])
import 'sign_in_test.mocks.dart'; // Archivo generado por build_runner

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tParams = SignInParams(email: tEmail, password: tPassword);

  test('debe llamar a authRepository.signIn y devolver Right(unit) en caso de éxito', () async {
    // ARRANGE: El Mock simula una respuesta exitosa del Repositorio.
    when(mockRepository.signIn(
      email: tEmail,
      password: tPassword,
    )).thenAnswer((_) async => const Right(unit));

    // ACT
    final result = await useCase(tParams);

    // ASSERT
    expect(result, const Right(unit));
    // Verifica que el Caso de Uso llamó exactamente a este método.
    verify(mockRepository.signIn(
      email: tEmail,
      password: tPassword,
    )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('debe propagar el Left(Failure) cuando el Repositorio falla', () async {
    // ARRANGE: El Mock simula un fallo de credenciales del Repositorio.
    const tFailure = InvalidCredentialsFailure();
    when(mockRepository.signIn(
      email: tEmail,
      password: tPassword,
    )).thenAnswer((_) async => const Left(tFailure));

    // ACT
    final result = await useCase(tParams);

    // ASSERT
    // El Caso de Uso simplemente devuelve el fallo que recibe.
    expect(result, const Left(tFailure));
    verify(mockRepository.signIn(email: tEmail, password: tPassword)).called(1);
  });
}
