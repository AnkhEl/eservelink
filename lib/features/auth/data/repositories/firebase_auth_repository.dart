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

  /// Get complete user by merging Firebase Auth with Firestore data
  Future<UserEntity?> _getCompleteUser(firebase_auth.User? firebaseUser) async {
    if (firebaseUser == null) return null;

    try {
      // Try to get user from Firestore (has role, restaurantId, etc.)
      final firestoreUserResult = await userRepository.getUserById(
        firebaseUser.uid,
      );

      return firestoreUserResult.fold(
        // If Firestore fetch fails, create basic user from Firebase Auth
        (failure) {
          return UserEntity(
            uid: firebaseUser.uid,
            email: firebaseUser.email!,
            displayName: firebaseUser.displayName,
            photoUrl: firebaseUser.photoURL,
            role: 'customer', // Default for new users
            emailVerified: firebaseUser.emailVerified,
            restaurantId: null,
          );
        },
        // If Firestore user exists, merge with latest Firebase Auth data
        (firestoreUser) {
          // Merge: Use Firestore data (role, restaurantId) + Firebase Auth data (emailVerified, etc.)
          return UserEntity(
            uid: firebaseUser.uid,
            email: firebaseUser.email!,
            displayName: firebaseUser.displayName ?? firestoreUser.displayName,
            photoUrl: firebaseUser.photoURL ?? firestoreUser.photoUrl,
            role: firestoreUser.role,
            emailVerified: firebaseUser.emailVerified,
            restaurantId: firestoreUser.restaurantId,
          );
        },
      );
    } catch (e) {
      // Fallback to basic user
      return UserEntity(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        role: 'customer',
        emailVerified: firebaseUser.emailVerified,
        restaurantId: null,
      );
    }
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
      final user = await _getCompleteUser(creds.user);
      return Right(user);
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

      await creds.user!.updateDisplayName(name);
      await creds.user!.reload();
      await creds.user!.sendEmailVerification();

      final updatedUser = firebaseAuth.currentUser;
      final completeUser = await _getCompleteUser(updatedUser);

      if (completeUser != null) {
        await userRepository.saveUserIfNotExists(completeUser);
      }

      return Right(completeUser);
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

      final creds = await firebase_auth.FirebaseAuth.instance
          .signInWithCredential(credential);

      final completeUser = await _getCompleteUser(creds.user);

      if (completeUser != null) {
        await userRepository.saveUserIfNotExists(completeUser);
      }

      return Right(completeUser);
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
      final completeUser = await _getCompleteUser(creds.user);

      if (completeUser != null) {
        await userRepository.saveUserIfNotExists(completeUser);
      }

      return Right(completeUser);
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
      final firebaseUser = firebaseAuth.currentUser;

      if (firebaseUser != null) {
        try {
          await firebaseUser.reload();
          final refreshedUser = firebaseAuth.currentUser;
          final userToUse = refreshedUser ?? firebaseUser;

          // Get complete user with Firestore data
          final completeUser = await _getCompleteUser(userToUse);
          return Right(completeUser);
        } catch (reloadError) {
          // If reload fails, still try to get complete user
          final completeUser = await _getCompleteUser(firebaseUser);
          return Right(completeUser);
        }
      }

      return const Right(null);
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

  @override
  Future<Either<Failure, bool>> checkEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
        final refreshedUser = firebaseAuth.currentUser;
        return Right(refreshedUser?.emailVerified ?? false);
      }
      return const Left(ServerFailure('No user found'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return const Right(null);
      }
      return const Left(
        ServerFailure('No user found or email already verified'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
