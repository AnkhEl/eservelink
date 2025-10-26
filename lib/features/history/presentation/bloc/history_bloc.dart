import 'package:eservelink/features/history/presentation/bloc/history_event.dart';
import 'package:eservelink/features/history/presentation/bloc/history_state.dart';
import 'package:eservelink/features/sessions/domain/usecases/get_user_sessions_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetUserSessionsUseCase getUserSessions;

  HistoryBloc({required this.getUserSessions}) : super(HistoryInitial()) {
    on<LoadUserSessionsEvent>(_onLoadUserSessions);
    on<RefreshHistoryEvent>(_onRefreshHistory);
  }

  Future<void> _onLoadUserSessions(
    LoadUserSessionsEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());

    final result = await getUserSessions(
      GetUserSessionsParams(customerId: event.customerId),
    );

    result.fold((failure) => emit(HistoryError(failure.message)), (sessions) {
      if (sessions.isEmpty) {
        emit(HistoryEmpty());
      } else {
        emit(HistoryLoaded(sessions));
      }
    });
  }

  Future<void> _onRefreshHistory(
    RefreshHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    // Keep current state while refreshing
    final result = await getUserSessions(
      GetUserSessionsParams(customerId: event.customerId),
    );

    result.fold((failure) => emit(HistoryError(failure.message)), (sessions) {
      if (sessions.isEmpty) {
        emit(HistoryEmpty());
      } else {
        emit(HistoryLoaded(sessions));
      }
    });
  }
}
