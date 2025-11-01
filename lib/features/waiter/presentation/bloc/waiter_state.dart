import 'package:equatable/equatable.dart';
import 'package:eservelink/features/waiter/domain/entities/waiter_session_entity.dart';

abstract class WaiterState extends Equatable {
  const WaiterState();

  @override
  List<Object?> get props => [];
}

class WaiterInitial extends WaiterState {}

class WaiterLoading extends WaiterState {}

/// Sessions loaded successfully
class WaiterSessionsLoaded extends WaiterState {
  final List<WaiterSessionEntity> waitingSessions;
  final List<WaiterSessionEntity> activeSessions;

  const WaiterSessionsLoaded({
    required this.waitingSessions,
    required this.activeSessions,
  });

  @override
  List<Object?> get props => [waitingSessions, activeSessions];

  int get totalPings =>
      [...waitingSessions, ...activeSessions].where((s) => s.hasPing).length;

  WaiterSessionsLoaded copyWith({
    List<WaiterSessionEntity>? waitingSessions,
    List<WaiterSessionEntity>? activeSessions,
  }) {
    return WaiterSessionsLoaded(
      waitingSessions: waitingSessions ?? this.waitingSessions,
      activeSessions: activeSessions ?? this.activeSessions,
    );
  }
}

/// Session joined successfully
class SessionJoined extends WaiterState {
  final WaiterSessionEntity session;

  const SessionJoined(this.session);

  @override
  List<Object?> get props => [session];
}

/// Session ended successfully
class SessionEnded extends WaiterState {
  final String message;

  const SessionEnded(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state
class WaiterError extends WaiterState {
  final String message;

  const WaiterError(this.message);

  @override
  List<Object?> get props => [message];
}
