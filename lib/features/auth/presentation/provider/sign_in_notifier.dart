import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

// Importa los componentes de la arquitectura
import '../../../../core/error/failures.dart';
import '../../../domain/usecases/sign_in_case.dart';
import '../../../domain/usecases/sign_up_case.dart';
import '../../../domain/usecases/check_auth_status.dart'; // Para la persistencia de la sesión

// Asumo que esta es tu clase de estado, pero la llamaremos AuthState
import 'sign_in_state.dart'; // Contiene la clase SignInState/AuthState
import '../../../domain/entities/user.dart'; // Tu UserEntity

// Renombraremos SignInNotifier a AuthNotifier
class AuthNotifier extends StateNotifier<SignInState> {
  // Use Cases inyectados (dependencias del Dominio)
  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;
  final CheckAuthStatusUseCase _checkStatus;

  AuthNotifier({
    required SignInUseCase signIn,
    required SignUpUseCase signUp,
    required CheckAuthStatusUseCase checkStatus,
  }) : _signIn = signIn,
        _signUp = signUp,
        _checkStatus = checkStatus,
        super(const SignInState.initial()) {
    // Iniciar la escucha para manejar la sesión persistente
    _listenToAuthStatus();
  }

  // ************************************************************
  // 1. Lógica de Persistencia de Sesión (usando Stream del Dominio)
  // ************************************************************
  void _listenToAuthStatus() {
    // Llama al Use Case que te da el Stream<Either<Failure, UserEntity?>>
    _checkStatus().call().listen((result) {
      result.fold(
        // Fallo en la verificación del estado (ej: error de red o lectura de token)
            (failure) => state = SignInState.error(failure.message),
        // Éxito: userEntity puede ser null (desconectado) o contener data
            (userEntity) {
          if (userEntity != null) {
            // Asumo que tu SignInState tiene un constructor success(UserEntity user)
            state = SignInState.success(userEntity);
          } else {
            // Usuario desconectado
            state = const SignInState.initial();
          }
        },
      );
    });
  }

  // ************************************************************
  // 2. Lógica de Registro (Reemplazando createUserWithEmailAndPassword)
  // ************************************************************
  @override
  Future<void> signInWithEmail(String email, String password) async {
    state = const SignInState.loading();

    // Llama al Use Case de Registro
    final result = await _signUp(SignUpParams(email: email, password: password));

    // El método fold de Dartz maneja Right (éxito) y Left (fallo)
    result.fold(
      // Lado Izquierdo (Failure):
          (failure) => state = SignInState.error(failure.message),
      // Lado Derecho (UserEntity): El Stream Listener se encargará de actualizar el estado
          (_) => {
        // El _listenToAuthStatus recibirá el nuevo UserEntity de Firebase
        // y lo pondrá en estado success. Solo detenemos el loading.
      },
    );
  }

  // ************************************************************
  // 3. Lógica de Inicio de Sesión (Reemplazando signInWithEmailAndPassword)
  // ************************************************************
  @override
  Future<void> loginWithEmail(String email, String password) async {
    state = const SignInState.loading();

    // Llama al Use Case de Inicio de Sesión
    final result = await _signIn(SignInParams(email: email, password: password));

    result.fold(
      // Left (Failure):
          (failure) => state = SignInState.error(failure.message),
      // Right (void): El Stream Listener se encargará de la transición final.
          (_) => {
        // Éxito: El _listenToAuthStatus() se actualiza automáticamente.
      },
    );
  }
}