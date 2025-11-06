import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../pages/sign_in_screen.dart';
import '../provider/sign_in_provider.dart';
import 'home_screen.dart';


class AuthFlowWrapper extends ConsumerWidget {
  const AuthFlowWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Observar el estado actual
    final authState = ref.watch(authNotifierProvider);

    // --- Lógica de Decisión ---

    // 3. Estado de Carga (Loading / Splash Screen)
    if (authState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 4. Estado de Éxito (Autenticado)
    // Evaluamos si la propiedad 'user' NO es null
    if (authState.user != null) {
      return const HomeScreen();
    }

    // 5. Estado Inicial / Error / Desconectado
    // Si no está cargando y 'user' es null, mostramos la pantalla de inicio de sesión.
    return const SignInScreen();
  }
}