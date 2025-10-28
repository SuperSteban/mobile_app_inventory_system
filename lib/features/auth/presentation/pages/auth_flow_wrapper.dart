import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../pages/sign_in_screen.dart';
import '../provider/sign_in_provider.dart'; // Tu pantalla de Login
// import 'home_screen.dart'; // Asume que tendrás una pantalla principal


class AuthFlowWrapper extends ConsumerWidget {
  const AuthFlowWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escucha el estado actual de autenticación
    final authState = ref.watch(authNotifierProvider);

    // Usa 'when' de Freezed para manejar todos los estados
    return authState.when(
      initial: () => const Center(child: Text('Cargando sesión...')), // Splash Screen temporal
      loading: () => const Center(child: CircularProgressIndicator()),

      // Si hay un usuario logueado, redirige a la app principal
      success: (user) {
        // Redirige al Home si el login es exitoso
        // En un proyecto real, esto sería 'const HomeScreen()'
        return const Center(child: Text('Autenticado. Bienvenido!'));
      },

      // Si hay error o no hay sesión, muestra la pantalla de login
      error: (message) => const SignInScreen(),
    );
  }
}