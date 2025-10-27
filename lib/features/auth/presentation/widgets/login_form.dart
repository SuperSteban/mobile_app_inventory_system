import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile_app_inventory_system/features/auth/presentation/provider/sign_in_state.dart';
import '../provider/sign_in_provider.dart';

class LoginForm extends HookConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final state = ref.watch(signInNotifierProvider);

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
          state.when(
            loading: () => const CircularProgressIndicator(),
            error: (message) => Text(message, style: const TextStyle(color: Colors.red)),
            initial: () => const SizedBox.shrink(),  // Nada para initial
            success: (_) => const SizedBox.shrink(),  // Nada para success (maneja en screen)
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(signInNotifierProvider.notifier).loginWithEmail(
                    emailController.text,
                    passwordController.text,
                  );
            },
            child: const Text('Iniciar Sesión'),
          ),
          TextButton(
            onPressed: () {
              ref.read(signInNotifierProvider.notifier).signInWithEmail(
                    emailController.text,
                    passwordController.text,
                  );
            },
            child: const Text('Registrarse'),
          ),
        ],
      ),
    );
  }
}