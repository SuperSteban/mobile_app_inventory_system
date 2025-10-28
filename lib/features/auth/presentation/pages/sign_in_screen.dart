import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../provider/sign_in_provider.dart'; // Contiene authNotifierProvider
import '../widgets/login_form.dart';
import '../provider//sign_in_state.dart'; // Contiene la clase SignInState


class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escuchar el Provider del Notifier (SignInState)
    ref.listen<SignInState>(authNotifierProvider, (previous, next) {

      next.when(
        initial: () => null, // No reaccionar al estado inicial
        loading: () => null, // No reaccionar al estado de carga

        success: (user) {
          // Lógica de Redirección o SnackBar para éxito
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('¡Bienvenido! Redirigiendo a Inventario...'),
          ));
          // Aquí iría la navegación: Navigator.of(context).pushReplacementNamed('/inventory');
        },

        error: (message) {
          // Lógica para mostrar el error (traducido por el Repositorio)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
      );
    });

    // 2. Observar el estado de carga para la UI
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login / Registro')),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const LoginForm(),

            // 3. Mostrar indicador de carga si el estado es .loading
            authState.when(
              // Usamos el método 'when' de Freezed para el switch de widgets
              loading: () => Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
              // En otros estados, mostramos un widget vacío (o la UI normal)
              initial: () => const SizedBox.shrink(),
              success: (user) => const SizedBox.shrink(),
              error: (message) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}