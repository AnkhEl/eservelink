import 'package:equatable/equatable.dart';

abstract class WaiterEvent extends Equatable {
  const WaiterEvent();

  @override
  List<Object?> get props => [];
}

/// Load waiting sessions for a restaurant
class LoadWaitingSessionsEvent extends WaiterEvent {
  final String restaurantId;

  const LoadWaitingSessionsEvent(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

/// Load active sessions for a waiter
class LoadWaiterActiveSessionsEvent extends WaiterEvent {
  final String waiterId;

  const LoadWaiterActiveSessionsEvent(this.waiterId);

  @override
  List<Object?> get props => [waiterId];
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

/// Refresh all sessions
class RefreshSessionsEvent extends WaiterEvent {
  final String waiterId;
  final String restaurantId;

  const RefreshSessionsEvent({
    required this.waiterId,
    required this.restaurantId,
  });

  @override
  List<Object?> get props => [waiterId, restaurantId];
}
