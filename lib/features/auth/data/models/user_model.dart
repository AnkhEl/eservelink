import 'package:eservelink/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.uid,
    required super.role,
    required super.emailVerified,
    required super.email,
    super.displayName,
    super.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      role: map['role'],
      email: map['email'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      emailVerified: map['emailVerified'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'emailVerified': emailVerified,
    };
  }
}
