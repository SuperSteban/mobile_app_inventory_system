// Ignora o elimina esta línea de importación temporal
// import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_inventory_system/features/auth/presentation/provider/sign_in_state.dart';


import '../../domain/use_cases/check_auth_status_case.dart';
import '../../domain/use_cases/sign_in_case.dart';


// Renombraremos SignInNotifier a AuthNotifier (asegúrate de que el archivo del provider use este nombre)
class AuthNotifier extends StateNotifier<AuthState> { // <--- Usando AuthState Inmutable

  final SignInUseCase _signIn;
  final CheckAuthStatusUseCase _checkStatus;

  AuthNotifier({
    required SignInUseCase signIn,
    required CheckAuthStatusUseCase checkStatus,
  }) : _signIn = signIn,
        _checkStatus = checkStatus,
        super(AuthState.initial()) { // <--- Usando constructor inicial sin Freezed
    _listenToAuthStatus();
  }

  // ************************************************************
  // 1. Lógica de Persistencia de Sesión
  // ************************************************************
  void _listenToAuthStatus() {
    _checkStatus.call().listen((result) {
      result.fold(
        // Fallo: Usamos copyWith para asignar el error
            (failure) => state = state.copyWith(error: failure, isLoading: false, clearUser: true),
            (userEntity) {
          // Éxito: Usamos copyWith para asignar el usuario o forzar la limpieza
          state = state.copyWith(
            user: userEntity,
            clearUser: userEntity == null, // Limpia el usuario si es null
            isLoading: false,
            clearError: true,
          );
        },
      );
    });
  }



  // ************************************************************
  // 3. Lógica de Inicio de Sesión
  // ************************************************************
  @override
  Future<void> loginWithEmail(String email, String password) async {
    // Usamos copyWith para establecer el estado de carga
    state = state.copyWith(isLoading: true, clearError: true);

    // Llama al Use Case de Inicio de Sesión
    final result = await _signIn(SignInParams(email: email, password: password));

    result.fold(
      // Left (Failure): Usamos copyWith para asignar el error
          (failure) => state = state.copyWith(error: failure, isLoading: false),
      // Right (void): Solo quitamos el estado de carga
          (_) => state = state.copyWith(isLoading: false),
    );
  }
}