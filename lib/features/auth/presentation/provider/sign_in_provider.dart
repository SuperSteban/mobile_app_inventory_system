import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'sign_in_notifier.dart';
import 'sign_in_state.dart';

final signInNotifierProvider = StateNotifierProvider<SignInNotifier, SignInState>(
  (ref) => SignInNotifier(),
);