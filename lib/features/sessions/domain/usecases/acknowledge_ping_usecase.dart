import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/sessions/domain/repositories/ping_repository.dart';

class AcknowledgePingUseCase {
  final PingRepository repository;

  AcknowledgePingUseCase(this.repository);

  Future<Either<Failure, void>> call(AcknowledgePingParams params) {
    return repository.acknowledgePing(
      pingId: params.pingId,
      sessionId: params.sessionId,
    );
  }
}

class AcknowledgePingParams {
  final String pingId;
  final String sessionId;

  AcknowledgePingParams({required this.pingId, required this.sessionId});
}
