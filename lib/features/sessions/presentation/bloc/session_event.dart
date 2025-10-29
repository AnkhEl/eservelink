import 'package:equatable/equatable.dart';
import 'package:eservelink/features/sessions/domain/entities/session_entity.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

class CreateSessionEvent extends SessionEvent {
  final String tableId;
  final String customerId;
  final String customerName;

  const CreateSessionEvent({
    required this.tableId,
    required this.customerId,
    required this.customerName,
  });

  @override
  List<Object> get props => [tableId, customerId, customerName];
}

class LoadActiveSessionEvent extends SessionEvent {
  final String customerId;

  const LoadActiveSessionEvent(this.customerId);

  @override
  List<Object> get props => [customerId];
}

class JoinSessionAsWaiterEvent extends SessionEvent {
  final String tableId;
  final String waiterId;
  final String waiterName;

  const JoinSessionAsWaiterEvent({
    required this.tableId,
    required this.waiterId,
    required this.waiterName,
  });

  @override
  List<Object> get props => [tableId, waiterId, waiterName];
}

class SendPingEvent extends SessionEvent {
  final String sessionId;
  final String customerId;
  final String customerName;
  final String tableNumber;
  final String? message;

  const SendPingEvent({
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

class CancelSessionEvent extends SessionEvent {
  final String sessionId;

  const CancelSessionEvent(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

//Navigation events
class ShowSessionWaitingEvent extends SessionEvent{
  final SessionEntity session;

  const ShowSessionWaitingEvent(this.session);
}
class ShowSessionActiveEvent extends SessionEvent{
  final SessionEntity session;

  const ShowSessionActiveEvent(this.session);
}
class ShowSessionHomeEvent extends SessionEvent{}
