import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/auth/domain/entities/user_entity.dart';
import 'package:eservelink/features/auth/data/models/user_model.dart';
import 'package:eservelink/features/auth/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore firestore;

  UserRepositoryImpl({required this.firestore});

  @override
  Future<Either<Failure, void>> saveUserIfNotExists(UserEntity user) async {
    try {
      final docRef = firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        final userModel = UserModel(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoUrl,
          role: user.role,
          emailVerified: user.emailVerified,
        );
        await docRef.set(userModel.toMap());
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to save user: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        return Left(ServerFailure('User not found'));
      }

      final data = doc.data()!;
      final userModel = UserModel.fromMap(data);
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch user: $e'));
    }
  }
}
