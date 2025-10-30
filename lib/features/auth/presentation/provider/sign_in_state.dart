import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';

class AuthState extends Equatable {
  final UserEntity? user;
  final bool isLoading;
  final Failure? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  factory AuthState.initial() => const AuthState(user: null, isLoading: false, error: null);

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