import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../provider/sign_in_provider.dart';
import '../widgets/login_form.dart';
import '../provider/sign_in_state.dart';


class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // 1. Escuchar el Provider para efectos secundarios (navegación, SnackBar)
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {

      // MANEJO DE ERRORES
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context)
            .hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!.message)),
        );

      }

      // MANEJO DE NAVEGACIÓN (ÉXITO)
      if (previous?.user == null && next.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('¡Bienvenido! Redirigiendo...'),
        ));
        // Ejemplo de navegación:
        // Navigator.of(context).pushReplacementNamed('/inventory');
      }
    });

    // 2. Observar el estado para actualizar la UI
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login / Registro')),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const LoginForm(),

            // 3. Mostrar indicador de carga global
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