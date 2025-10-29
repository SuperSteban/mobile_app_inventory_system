import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Importación de la función de configuración de GetIt
import 'di/service_locator.dart';
import 'firebase_options.dart';

// Importaciones de la Capa de Presentación
import 'features/auth/presentation/pages/auth_flow_wrapper.dart';


void main() async {
  // 1. Inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicialización de Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Inicialización de la Inyección de Dependencias (Get_it)
  // CRÍTICO: Esta función registra todos los Repositorios y Use Cases.
  setupDependencies();

  // 4. Ejecutar la aplicación
  runApp(const ProviderScope(child: MyApp()));
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