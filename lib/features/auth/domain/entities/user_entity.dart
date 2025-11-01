import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String role; // 'admin', 'cu', 'customer'
  final bool emailVerified;
  final String? restaurantId;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.role,
    required this.emailVerified,
    this.restaurantId,
  });

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    photoUrl,
    role,
    emailVerified,
    restaurantId,
  ];
}
