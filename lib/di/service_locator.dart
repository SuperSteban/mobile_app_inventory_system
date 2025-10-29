import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- Imports de Features ---
// 1. Domain (Contratos y Use Cases)
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/use_cases/sign_in_case.dart';
import '../features/auth/domain/use_cases/check_auth_status_case.dart';

// 2. Data (Implementaciones)
import '../features/auth/data/data_sources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository.dart';

final sl = GetIt.instance; // Instancia global de GetIt

void setupDependencies() {
  // ----------------------------------------------------
  // 1. CAPA DE INFRAESTRUCTURA (Librerías externas)
  // ----------------------------------------------------
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  // ----------------------------------------------------
  // 2. CAPA DE DATA (Implementación de Repositorio y Data Sources)
  // ----------------------------------------------------

  // Data Source (Habla con FirebaseAuth)
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );

  // Repositorio (Traductor de Data a Domain)
  // Registramos la implementación concreta para la interfaz abstracta
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // ----------------------------------------------------
  // 3. CAPA DE DOMINIO (Use Cases)
  // ----------------------------------------------------

  // Registramos los Use Cases para que el Notifier pueda accederlos
  sl.registerFactory(() => SignInUseCase(sl()));
  sl.registerFactory(() => CheckAuthStatusUseCase(sl()));
}