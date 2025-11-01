// lib/features/auth/data/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/auth/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.photoUrl,
    required super.role,
    required super.emailVerified,
    super.restaurantId,
  });

  /// Create from Firebase Auth User
  factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      role: 'customer', // Default role, will be updated from Firestore
      emailVerified: firebaseUser.emailVerified,
      restaurantId: null, // Will be fetched from Firestore
    );
  }

  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      role: data['role'] ?? 'customer',
      emailVerified: data['emailVerified'] ?? false,
      restaurantId: data['restaurantId'], // Add restaurantId from Firestore
    );
  }

  //create from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      role: map['role'],
      email: map['email'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      emailVerified: map['emailVerified'],
      restaurantId: map["restaurantId"],
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'emailVerified': emailVerified,
      'restaurantId': restaurantId, // Include restaurantId in Firestore
    };
  }

  /// Create from entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      role: entity.role,
      emailVerified: entity.emailVerified,
      restaurantId: entity.restaurantId,
    );
  }

  /// Convert to entity
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      role: role,
      emailVerified: emailVerified,
      restaurantId: restaurantId,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? role,
    bool? emailVerified,
    String? restaurantId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      restaurantId: restaurantId ?? this.restaurantId,
    );
  }
}
