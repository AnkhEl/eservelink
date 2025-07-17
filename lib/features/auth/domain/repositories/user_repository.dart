import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/auth/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, void>> saveUserIfNotExists(UserEntity user);
  Future<Either<Failure, UserEntity>> getUserById(String uid);
}
