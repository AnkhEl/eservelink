import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object> get props => [];
}

class LoadUserSessionsEvent extends HistoryEvent {
  final String customerId;

  const LoadUserSessionsEvent(this.customerId);

  @override
  List<Object> get props => [customerId];
}

class RefreshHistoryEvent extends HistoryEvent {
  final String customerId;

  const RefreshHistoryEvent(this.customerId);

  @override
  List<Object> get props => [customerId];
}
