import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/auth/domain/repositories/auth_repository.dart';

class CheckEmailVerification implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  const CheckEmailVerification(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.checkEmailVerification();
  }
}
