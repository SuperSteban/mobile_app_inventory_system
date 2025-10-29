import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:get_it/get_it.dart';

// --- Importaciones de la Capa de Lógica y Estado ---
import 'sign_in_notifier.dart'; // Tu clase StateNotifier (AuthNotifier)
import 'sign_in_state.dart';        // Tu clase de Estado Inmutable (AuthState)

// --- Importaciones de la Capa de Dominio (Use Cases) ---
import '../../domain/use_cases/sign_in_case.dart';
import '../../domain/use_cases/check_auth_status_case.dart';


final sl = GetIt.instance; // Instancia global de GetIt

// CRÍTICO: Definimos el StateNotifierProvider
// Asumo que el tipo de estado final es AuthState para mayor claridad
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
      (ref) {
    // 1. INYECCIÓN COMPLETA DE DEPENDENCIAS (DI)
    // Se inyectan los tres Use Cases (SignIn, SignUp, CheckStatus)
    return AuthNotifier(
      signIn: sl<SignInUseCase>(),
      checkStatus: sl<CheckAuthStatusUseCase>(),
    );
  },
);

// Puedes mantener providers simples para exponer Use Cases individualmente si es necesario:
final signInUseCaseProvider = Provider<SignInUseCase>((ref) => sl<SignInUseCase>());