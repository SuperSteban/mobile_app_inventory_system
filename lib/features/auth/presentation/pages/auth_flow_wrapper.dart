import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../pages/sign_in_screen.dart';
import '../provider/sign_in_provider.dart';

// Importamos el estado para poder usarlo en la escucha (aunque no es estrictamente necesario aquí)


class AuthFlowWrapper extends ConsumerWidget {
  const AuthFlowWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Observar el estado actual
    final authState = ref.watch(authNotifierProvider);

    // 2. Leer el Notifier para llamar a los métodos
    final notifier = ref.read(authNotifierProvider.notifier);

    // --- Lógica de Decisión ---

    // 3. Estado de Carga (Loading / Splash Screen)
    if (authState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 4. Estado de Éxito (Autenticado)
    // Evaluamos si la propiedad 'user' NO es null
    if (authState.user != null) {
      final user = authState.user!; // Obtenemos la entidad garantizada

      return Scaffold(
        appBar: AppBar(
          title: const Text('Home / Inventario'),
          actions: [
            TextButton(
              onPressed: authState.isLoading ? null : () {
                // Llama al método signOut del AuthNotifier
                notifier.signOut();
              },
              child: authState.isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Autenticado. Bienvenido, ${user.email}!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Esta es la pantalla principal del Inventario (HomeScreen).'),
              ),
            ],
          ),
        ),
      );
    }

    // 5. Estado Inicial / Error / Desconectado
    // Si no está cargando y 'user' es null, mostramos la pantalla de inicio de sesión.
    // 🟢 ESTO ES LA REDIRECCIÓN AUTOMÁTICA
    return const SignInScreen();
  }
}