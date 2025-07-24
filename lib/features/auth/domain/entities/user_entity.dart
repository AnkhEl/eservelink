class UserEntity {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String role; // 'admin', 'cu', 'customer'
  final bool emailVerified;

  UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.role,
    required this.emailVerified,
  });
}
