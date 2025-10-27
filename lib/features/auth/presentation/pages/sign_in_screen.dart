import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../provider/sign_in_provider.dart';
import '../widgets/login_form.dart';
import '../provider/sign_in_state.dart';  // Agrega este import para SignInState y 'when'

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SignInState>(signInNotifierProvider, (previous, next) {
      if (next != null) {
        next.when(
          success: (user) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Bienvenido!')));
            // En Sprint 2: Navigator.pushReplacementNamed(context, '/inventory');
          },
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          },
          initial: () {},
          loading: () {},
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Login / Registro')),
      body: const Center(child: LoginForm()),
    );
  }
}