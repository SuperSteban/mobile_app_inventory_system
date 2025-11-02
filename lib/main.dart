import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Importación de la función de configuración de GetIt
import 'di/service_locator.dart';
import 'firebase_options.dart';

// Importaciones de la Capa de Presentación
import 'features/auth/presentation/pages/auth_flow_wrapper.dart';


void main() async {
  // 1. Inicialización de Flutter
  WidgetsBinding widgetsBinding =  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: (widgetsBinding));
  await _initializeApp();
  // 4. Ejecutar la aplicación
  runApp(const ProviderScope(child: MyApp()));
}

// Función separada para manejar toda la lógica de inicialización.
Future<void> _initializeApp() async {
  // 1. Inicialización de Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 2. Inicialización de la Inyección de Dependencias (Get_it)
  // CRÍTICO: Esta función registra todos los Repositorios y Use Cases.
  setupDependencies();

  // 3. Simulamos una pequeña espera si es necesario, o cargamos datos iniciales.
  // Quítalo si no lo necesitas.
  await Future.delayed(const Duration(seconds: 1));

  // 4. ¡CRÍTICO! Eliminar la pantalla nativa de splash
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory System UTH',
      theme: ThemeData(primarySwatch: Colors.green),
      // Usamos el AuthFlowWrapper para que Riverpod decida la pantalla (Login vs Home).
      home: const AuthFlowWrapper(),
    );
  }
}