import 'package:dartz/dartz.dart';

import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity?>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity?>> registerWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, UserEntity?>> signInWithGoogle();

  Future<Either<Failure, UserEntity?>> signInWithApple();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, void>> resetPassword({required String email});

  Future<Either<Failure, void>> sendEmailVerification();

  Future<Either<Failure, bool>> checkEmailVerification();
}
