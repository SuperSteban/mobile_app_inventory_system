import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/entities/user.dart';
import '../pages/sign_in_screen.dart';
import '../provider/sign_in_provider.dart';



class AuthFlowWrapper extends ConsumerWidget {
  const AuthFlowWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escuchar el estado actual
    final authState = ref.watch(authNotifierProvider);

    // --- Lógica de Decisión Sin Freezed ---

    // 2. Estado de Carga (Loading / Splash Screen)
    if (authState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 3. Estado de Éxito (Autenticado)
    // Evaluamos si la propiedad 'user' NO es null
    if (authState.user != null) {
      // Si el usuario existe, se asume que es la HomeScreen.
      final user = authState.user!; // Obtenemos la entidad garantizada
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Autenticado. Bienvenido, ${user.email}!'),
            const Text('Esta es la HomeScreen.'),
          ],
        ),
      );
    }

    // 4. Estado Inicial / Error / Desconectado
    // Si no está cargando y 'user' es null, mostramos la pantalla de inicio de sesión.
    return const SignInScreen();
  }
}