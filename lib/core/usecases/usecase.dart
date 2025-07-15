import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';

/// The generic base class for all use cases.
///
/// [Type] is the return type.
/// [Params] is the parameter type (can be `NoParams` if not needed).
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this when the use case does not require any parameters.
class NoParams {}
