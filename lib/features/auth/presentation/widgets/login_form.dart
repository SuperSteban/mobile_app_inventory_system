import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../provider/sign_in_provider.dart';

class LoginForm extends HookConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    // 1. Observar el estado (AuthState)
    final state = ref.watch(authNotifierProvider);
    // 2. Leer el Notifier para llamar al método de login
    final notifier = ref.read(authNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'Contraseña'),
            obscureText: true,
          ),
          const SizedBox(height: 24),

          // --- Manejo de Carga y Errores ---
          if (state.isLoading)
            const CircularProgressIndicator()
          else if (state.error != null)
            Text(state.error!.message, style: const TextStyle(color: Colors.red)),

          const SizedBox(height: 24), // Espacio fijo

          ElevatedButton(
            // Deshabilitar botón durante la carga
            onPressed: state.isLoading
                ? null
                : () {
              notifier.loginWithEmail(
                emailController.text,
                passwordController.text,
              );
            },
            child: const Text('Iniciar Sesión'),
          ),
          // TextButton para Registrarse ELIMINADO
        ],
      ),
    );
  }
}