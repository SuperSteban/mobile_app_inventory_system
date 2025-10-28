import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../provider/sign_in_notifier.dart';
import '../provider/sign_in_state.dart';

// Importar los Use Cases
import '../../../domain/usecases/sign_in.dart';
import '../../../domain/usecases/sign_up.dart';
import '../../../domain/usecases/check_auth_status.dart';


final sl = GetIt.instance; // Instancia global de GetIt


final authNotifierProvider = StateNotifierProvider<AuthNotifier, SignInState>(
      (ref) {
    // Inyección de Dependencias de los Use Cases vía GetIt
    return AuthNotifier(
      signIn: sl<SignInUseCase>(),
      signUp: sl<SignUpUseCase>(),
      checkStatus: sl<CheckAuthStatusUseCase>(),
    );
  },
);