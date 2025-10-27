import 'package:equatable/equatable.dart';
// Import your Domain Entity. Note: You should check if UserEntity has a 'password' field.
// If it's a standard entity, it should use uid/email/name.
import 'package:mobile_app_inventory_system/features/auth/domain/entities/user.dart' as domain;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String? name;

  const UserModel({
    required this.uid,
    required this.email,
    this.name,
  });

  // FIX 2 & 3: Mapped properties correctly from firebase_auth.User.
  // The Data Layer's job is to read and serialize Firebase data.
  factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName, // displayName is often null
    );
  }

  // FIX 4: Mapping to the Domain Entity (assumes Domain Entity also uses uid/email/name)
  domain.UserEntity toEntity() => domain.UserEntity(
    uid: uid,
    email: email,
    name: name,
  );

  @override
  List<Object?> get props => [uid, email, name];
}