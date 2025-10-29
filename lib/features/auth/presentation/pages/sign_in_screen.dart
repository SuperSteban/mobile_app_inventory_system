import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../provider/sign_in_provider.dart'; // Contiene authNotifierProvider (Asumo que renombraste)
import '../widgets/login_form.dart';
import '../provider/sign_in_state.dart'; // Importa la clase de estado inmutable (AuthState)


class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // 1. Escuchar el Provider. Se tipa con el estado inmutable: AuthState.
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {

      // --- Lógica de Manejo de Side Effects (Sin .when) ---

      // MANEJO DE ERRORES: Si existe un nuevo error, lo mostramos.
      if (next.error != null && next.error != previous?.error) {
        // Muestra el mensaje de la Failure (el mensaje viene de la propiedad del estado)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!.message)),
        );
      }

      // MANEJO DE NAVEGACIÓN (ÉXITO): Si el usuario anterior era null y el nuevo NO lo es.
      if (previous?.user == null && next.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('¡Bienvenido! Redirigiendo a Inventario...'),
        ));
        // Aquí iría la navegación a la HomeScreen
        // Navigator.of(context).pushReplacementNamed('/inventory');
      }
    });

    // 2. Observar el estado completo para actualizar la UI
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login / Registro')),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const LoginForm(),

            // 3. Mostrar indicador de carga
            // CRÍTICO: Accedemos directamente a la propiedad 'isLoading'
            if (authState.isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}