import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/sessions/domain/repositories/ping_repository.dart';
import 'package:eservelink/features/sessions/domain/repositories/session_repository.dart';

class SendPingUseCase implements UseCase<void, SendPingParams> {
  final PingRepository pingRepository;
  final SessionRepository sessionRepository;

  SendPingUseCase({
    required this.pingRepository,
    required this.sessionRepository,
  });

  @override
  Future<Either<Failure, void>> call(SendPingParams params) async {
    // Update last ping time in session
    final sessionResult = await sessionRepository.getSessionById(
      params.sessionId,
    );

    return await sessionResult.fold((failure) => Left(failure), (
      session,
    ) async {
      // Send ping
      return await pingRepository.sendPing(
        sessionId: params.sessionId,
        customerId: params.customerId,
        customerName: params.customerName,
        tableNumber: params.tableNumber,
        message: params.message,
      );
    });
  }
}

class SendPingParams extends Equatable {
  final String sessionId;
  final String customerId;
  final String customerName;
  final String tableNumber;
  final String? message;

  const SendPingParams({
    required this.sessionId,
    required this.customerId,
    required this.customerName,
    required this.tableNumber,
    this.message,
  });

  @override
  List<Object?> get props => [
    sessionId,
    customerId,
    customerName,
    tableNumber,
    message,
  ];
}
