import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/auth/domain/repositories/auth_repository.dart';

class SendEmailVerification implements UseCase<void, NoParams> {
  final AuthRepository repository;

  const SendEmailVerification(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.sendEmailVerification();
  }
}
