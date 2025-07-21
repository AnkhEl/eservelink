import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/auth/domain/entities/user_entity.dart';
import 'package:eservelink/features/auth/domain/repositories/auth_repository.dart';

class RegisterWithEmail
    implements UseCase<UserEntity?, RegisterWithEmailParams> {
  final AuthRepository repository;

  RegisterWithEmail(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(
    RegisterWithEmailParams params,
  ) async {
    final result = await repository.registerWithEmail(
      email: params.email,
      password: params.password,
      name: params.name,
    );

    return result.fold(
      (failure) =>
          Left(UnexpectedFailure("Registration failed: ${failure.message}")),
      (user) {
        if (user == null) {
          return Left(UnexpectedFailure('Registration failed'));
        } else {
          return Right(user);
        }
      },
    );
  }
}

class RegisterWithEmailParams {
  final String email;
  final String password;
  final String name;

  RegisterWithEmailParams({
    required this.name,
    required this.email,
    required this.password,
  });
}
