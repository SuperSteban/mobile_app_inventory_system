import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/pages/sign_in_screen.dart';

void main() async {
  // 1. Inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicialización de Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Inicialización de la Inyección de Dependencias (Get_it)
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
      // CRÍTICO: Usamos el Wrapper para manejar la lógica de sesión/splash
      home: const AuthFlowWrapper(),
    );
  }
}