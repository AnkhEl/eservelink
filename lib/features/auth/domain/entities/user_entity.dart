class UserEntity {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String role; // 'admin', 'cu', 'customer'

  UserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.role,
  });
}
