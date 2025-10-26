import 'package:equatable/equatable.dart';
import 'package:eservelink/features/sessions/domain/entities/session_entity.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<SessionEntity> sessions;

  const HistoryLoaded(this.sessions);

  @override
  List<Object> get props => [sessions];
}

class HistoryEmpty extends HistoryState {}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object> get props => [message];
}
