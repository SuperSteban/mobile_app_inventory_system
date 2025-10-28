import 'package:freezed_annotation/freezed_annotation.dart';
// Importa la Entidad Pura de Dominio (Asumo que esta es la ruta correcta)
import '../../../domain/entities/user.dart';

part 'sign_in_state.freezed.dart';

@freezed
class SignInState with _$SignInState {
  const factory SignInState.initial() = _Initial;
  const factory SignInState.loading() = _Loading;

  // Usar UserEntity de tu Dominio.
  const factory SignInState.success(UserEntity user) = _Success;

  const factory SignInState.error(String message) = _Error;
}