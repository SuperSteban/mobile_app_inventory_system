import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_inventory_system/features/auth/presentation/provider/sign_in_state.dart';
import '../../domain/use_cases/check_auth_status_case.dart';
import '../../domain/use_cases/sign_in_case.dart';
import '../../domain/use_cases/sign_out_case.dart';

class AuthNotifier extends StateNotifier<AuthState> {

  final SignInUseCase _signIn;
  final SignOutUseCase _signOut;
  // final SignUpUseCase _signUp; <--- ELIMINADO
  final CheckAuthStatusUseCase _checkStatus;

  AuthNotifier({
    required SignInUseCase signIn,
    required SignOutUseCase signOut,
    required CheckAuthStatusUseCase checkStatus,
  }) : _signIn = signIn,
        _signOut = signOut,
        _checkStatus = checkStatus,
        super(AuthState.initial()) {
    _listenToAuthStatus();
  }
// ************************************************************
  // Nuevo: Lógica de Cierre de Sesión
  // ************************************************************
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _signOut(); // Llama al Use Case

    result?.fold(
          (failure) => state = state.copyWith(error: failure, isLoading: false),
          (_) {
        // Al cerrar sesión, el estado del usuario pasará a null.
        // El _listenToAuthStatus() detectará esto y actualizará el estado,
        // pero podemos forzar la limpieza y quitar la carga aquí también.
        state = state.copyWith(isLoading: false, clearUser: true);
      },
    );
  }
  void _listenToAuthStatus() {
    _checkStatus.call().listen((result) {
      result.fold(
            (failure) => state = state.copyWith(error: failure, isLoading: false, clearUser: true),
            (userEntity) {
          state = state.copyWith(
            user: userEntity,
            clearUser: userEntity == null,
            isLoading: false,
            clearError: true,
          );
        },
      );
    });
  }

  // Lógica de Inicio de Sesión
  Future<void> loginWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _signIn(SignInParams(email: email, password: password));

    result.fold(
          (failure) => state = state.copyWith(error: failure, isLoading: false),
          (_) => state = state.copyWith(isLoading: false),
    );
  }

}