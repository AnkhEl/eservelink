import 'package:equatable/equatable.dart';
import 'package:eservelink/features/waiter/domain/entities/waiter_session_entity.dart';

abstract class WaiterEvent extends Equatable {
  const WaiterEvent();

  @override
  List<Object?> get props => [];
}

/// Start watching sessions in real-time
class StartWatchingSessionsEvent extends WaiterEvent {
  final String restaurantId;
  final String waiterId;

  const StartWatchingSessionsEvent({
    required this.restaurantId,
    required this.waiterId,
  });

  @override
  List<Object?> get props => [restaurantId, waiterId];
}

/// Stop watching sessions
class StopWatchingSessionsEvent extends WaiterEvent {}

/// Internal event when sessions are updated from stream
class SessionsUpdatedEvent extends WaiterEvent {
  final List<WaiterSessionEntity> waitingSessions;
  final List<WaiterSessionEntity> activeSessions;

  const SessionsUpdatedEvent({
    required this.waitingSessions,
    required this.activeSessions,
  });

  @override
  List<Object?> get props => [waitingSessions, activeSessions];
}

/// Join a session by scanning table QR
class JoinSessionEvent extends WaiterEvent {
  final String tableId;
  final String waiterId;
  final String waiterName;

  const JoinSessionEvent({
    required this.tableId,
    required this.waiterId,
    required this.waiterName,
  });

  @override
  List<Object?> get props => [tableId, waiterId, waiterName];
}

/// End a session
class EndSessionEvent extends WaiterEvent {
  final String sessionId;

  const EndSessionEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Show WaiterSessionPage
class ShowWaiterSessionEvent extends WaiterEvent {
  final WaiterSessionEntity session;

  const ShowWaiterSessionEvent(this.session);
}

/// Show WaiterHomePage
class ShowWaiterHomeEvent extends WaiterEvent {}
