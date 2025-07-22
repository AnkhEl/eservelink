import 'package:dartz/dartz.dart';
import 'package:eservelink/features/auth/domain/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/auth/domain/entities/user_entity.dart';
import 'package:eservelink/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final UserRepository userRepository;

  FirebaseAuthRepository({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.userRepository,
  });

  UserEntity? _userFromFirebaseUser(firebase_auth.User? user) {
    if (user == null) return null;
    return UserEntity(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL ?? "",
      role: 'customer',
    );
  }

  @override
  Future<Either<Failure, UserEntity?>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final creds = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(_userFromFirebaseUser(creds.user));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final creds = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await creds.user?.updateDisplayName(name);
      await creds.user?.reload(); // Ensure the changes reflect
      final updatedUser = firebaseAuth.currentUser;
      final updatedUserEntity = _userFromFirebaseUser(updatedUser);
      await userRepository.saveUserIfNotExists(updatedUserEntity!);
      return Right(updatedUserEntity);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(ServerFailure(_mapFirebaseAuthError(e.code)));
    } catch (_) {
      return Left(ServerFailure('Registration failed'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate(scopeHint: ['email']);
      final authorization = await googleUser.authorizationClient
          .authorizationForScopes(['email']);
      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
        accessToken: authorization?.accessToken,
      );
      // Firebase sign‑in
      final creds = await firebase_auth.FirebaseAuth.instance
          .signInWithCredential(credential);
      final userEntity = _userFromFirebaseUser(creds.user);
      await userRepository.saveUserIfNotExists(userEntity!);
      return Right(userEntity);
    } on GoogleSignInException catch (e) {
      return Left(ServerFailure('Google sign-in failed: ${e.code.name}'));
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firebase Auth error'));
    } on FormatException {
      return const Left(ServerFailure('Bad response format'));
    } on PlatformException catch (e) {
      return Left(ServerFailure('Platform error: ${e.code}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = firebase_auth.OAuthProvider("apple.com");
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final creds = await firebaseAuth.signInWithCredential(credential);
      return Right(_userFromFirebaseUser(creds.user));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await firebaseAuth.signOut();
      await googleSignIn.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      return Right(_userFromFirebaseUser(firebaseAuth.currentUser));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'weak-password':
        return 'Password is too weak.';
      default:
        return 'An unknown error occurred.';
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(ServerFailure(_mapFirebaseAuthError(e.code)));
    } catch (e) {
      return Left(
        ServerFailure('Failed to send password reset email: ${e.toString()}'),
      );
    }
  }
}
