import 'package:equatable/equatable.dart';
import 'package:eservelink/features/sessions/domain/entities/session_entity.dart';

abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

class SessionCreating extends SessionState {
  final String tableId;

  const SessionCreating(this.tableId);

  @override
  List<Object> get props => [tableId];
}

class SessionCreated extends SessionState {
  final SessionEntity session;

  const SessionCreated(this.session);

  @override
  List<Object> get props => [session];
}

class SessionActive extends SessionState {
  final SessionEntity session;

  const SessionActive(this.session);

  @override
  List<Object> get props => [session];
}

class SessionWaitingForWaiter extends SessionState {
  final SessionEntity session;

  const SessionWaitingForWaiter(this.session);

  @override
  List<Object> get props => [session];
}

class NoActiveSession extends SessionState {}

class SessionError extends SessionState {
  final String message;

  const SessionError(this.message);

  @override
  List<Object> get props => [message];
}

class PingSent extends SessionState {
  final SessionEntity session;

  const PingSent(this.session);

  @override
  List<Object> get props => [session];
}

// Navigation States
class SessionShowWaiting extends SessionState {
  final SessionEntity session;

  const SessionShowWaiting(this.session);

  @override
  List<Object?> get props => [session];
}

class SessionShowActive extends SessionState {
  final SessionEntity session;

  const SessionShowActive(this.session);

  @override
  List<Object?> get props => [session];
}

class SessionShowHome extends SessionState {}

