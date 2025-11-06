// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Auth ---
import '../features/auth/data/repositories/auth_repository.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/use_cases/sign_in_case.dart';
import '../features/auth/domain/use_cases/check_auth_status_case.dart';
import '../features/auth/domain/use_cases/sign_out_case.dart';
import '../features/auth/data/data_sources/auth_remote_data_source.dart';

// --- Products ---
import '../features/products/data/datasources/firebase_product_datasource.dart';
import '../features/products/domain/repositories/product_repository.dart';
import '../features/products/domain/use_cases/add_product_case.dart';
import '../features/products/domain/use_cases/get_products_case.dart';
import '../features/products/domain/use_cases/update_product_case.dart';
import '../features/products/data/repositories/product_repository_impl.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // ========================================
  // 1. INFRAESTRUCTURA (Firebase)
  // ========================================
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  // ========================================
  // 2. DATA LAYER (Implementaciones)
  // ========================================

  // --- Auth ---
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(firebaseAuth: sl<FirebaseAuth>()),
  );

  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
  );

  // --- Products ---
  sl.registerLazySingleton<FirebaseProductDatasource>(
        () => FirebaseProductDatasource(),
  );
  sl.registerLazySingleton<ProductRepository>(
        () => ProductRepositoryImpl(
      firestore: sl<FirebaseFirestore>(),
      datasource: sl<FirebaseProductDatasource>(),
    ),
  );

  // ========================================
  // 3. DOMAIN LAYER (Use Cases)
  // ========================================

  // --- Auth ---
  sl.registerFactory<SignInUseCase>(() => SignInUseCase(sl<AuthRepository>()));
  sl.registerFactory<CheckAuthStatusUseCase>(() => CheckAuthStatusUseCase(sl<AuthRepository>()));
  sl.registerFactory<SignOutUseCase>(() => SignOutUseCase(sl<AuthRepository>()));

  // --- Products ---
  sl.registerLazySingleton<GetProductsCase>(() => GetProductsCase(sl<ProductRepository>()));
  sl.registerLazySingleton<AddProductCase>(() => AddProductCase(sl<ProductRepository>()));
  sl.registerLazySingleton<UpdateProductCase>(() => UpdateProductCase(sl<ProductRepository>()));
}