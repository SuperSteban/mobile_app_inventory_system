import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:get_it/get_it.dart';

// --- Importaciones de la Capa de Lógica y Estado ---
import 'sign_in_notifier.dart';
import 'sign_in_state.dart';

// --- Importaciones de la Capa de Dominio (Use Cases) ---
import '../../domain/use_cases/sign_in_case.dart';
import '../../domain/use_cases/check_auth_status_case.dart';
import '../../domain/use_cases/sign_out_case.dart';

final sl = GetIt.instance;

// StateNotifierProvider simplificado

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
      (ref) {
    return AuthNotifier(
      signIn: sl<SignInUseCase>(),
      checkStatus: sl<CheckAuthStatusUseCase>(),
      signOut: sl<SignOutUseCase>(),
    );
  },
);

final signInUseCaseProvider = Provider<SignInUseCase>((ref) => sl<SignInUseCase>());