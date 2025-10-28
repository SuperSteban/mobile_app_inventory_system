import 'package:equatable/equatable.dart';

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


  factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName, // displayName is often null
    );
  }

  domain.UserEntity toEntity() => domain.UserEntity(
    uid: uid,
    email: email,
    name: name,
  );

  @override
  List<Object?> get props => [uid, email, name];
}