// lib/features/auth/data/repositories/firebase_auth_repository.dart

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/auth/domain/entities/user_entity.dart';
import 'package:eservelink/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  FirebaseAuthRepository({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  UserEntity? _userFromFirebaseUser(firebase_auth.User? user) {
    if (user == null) return null;
    return UserEntity(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      role: 'unknown', // You can load this from Firestore later
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
  }) async {
    try {
      final creds = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(_userFromFirebaseUser(creds.user));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      if (googleUser == null) return Right(null);

      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        return Left(ServerFailure('Missing Google ID token'));
      }

      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final creds = await firebaseAuth.signInWithCredential(credential);
      return Right(_userFromFirebaseUser(creds.user));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
}
