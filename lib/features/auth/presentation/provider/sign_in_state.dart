import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';

// El estado ahora es una clase inmutable tradicional con Equatable.
class AuthState extends Equatable {
  // CRÍTICO: Estas propiedades son accesibles directamente por los widgets
  final UserEntity? user;
  final bool isLoading;
  final Failure? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  // Estado inicial (desconectado)
  factory AuthState.initial() => const AuthState(user: null, isLoading: false, error: null);

  // Método esencial para la inmutabilidad: crea una nueva instancia con los valores modificados
  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    Failure? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [user, isLoading, error];
}