import 'package:eservelink/features/waiter/domain/entities/waiter_session_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eservelink/features/waiter/domain/usecases/get_waiting_sessions_usecase.dart';
import 'package:eservelink/features/waiter/domain/usecases/get_waiter_active_sessions_usecase.dart';
import 'package:eservelink/features/waiter/domain/usecases/join_session_usecase.dart';
import 'package:eservelink/features/waiter/domain/usecases/end_session_usecase.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_event.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_state.dart';

class WaiterBloc extends Bloc<WaiterEvent, WaiterState> {
  final GetWaitingSessionsUseCase getWaitingSessions;
  final GetWaiterActiveSessionsUseCase getWaiterActiveSessions;
  final JoinSessionUseCase joinSession;
  final EndSessionUseCase endSession;

  WaiterBloc({
    required this.getWaitingSessions,
    required this.getWaiterActiveSessions,
    required this.joinSession,
    required this.endSession,
  }) : super(WaiterInitial()) {
    on<LoadWaitingSessionsEvent>(_onLoadWaitingSessions);
    on<LoadWaiterActiveSessionsEvent>(_onLoadWaiterActiveSessions);
    on<JoinSessionEvent>(_onJoinSession);
    on<EndSessionEvent>(_onEndSession);
    on<RefreshSessionsEvent>(_onRefreshSessions);
  }

  Future<void> _onLoadWaitingSessions(
    LoadWaitingSessionsEvent event,
    Emitter<WaiterState> emit,
  ) async {
    // Don't show loading if we already have sessions
    if (state is! WaiterSessionsLoaded) {
      emit(WaiterLoading());
    }

    final result = await getWaitingSessions(
      GetWaitingSessionsParams(restaurantId: event.restaurantId),
    );

    result.fold(
      (failure) {
        emit(WaiterError(failure.message));
      },
      (waitingSessions) {
        // Preserve active sessions if we have them
        final currentActiveSessions =
            state is WaiterSessionsLoaded
                ? (state as WaiterSessionsLoaded).activeSessions
                : <WaiterSessionEntity>[];

        emit(
          WaiterSessionsLoaded(
            waitingSessions: waitingSessions,
            activeSessions: currentActiveSessions,
          ),
        );
      },
    );
  }

  Future<void> _onLoadWaiterActiveSessions(
    LoadWaiterActiveSessionsEvent event,
    Emitter<WaiterState> emit,
  ) async {
    // Don't show loading if we already have sessions
    if (state is! WaiterSessionsLoaded) {
      emit(WaiterLoading());
    }

    final result = await getWaiterActiveSessions(
      GetWaiterActiveSessionsParams(waiterId: event.waiterId),
    );

    result.fold(
      (failure) {
        emit(WaiterError(failure.message));
      },
      (activeSessions) {
        // Preserve waiting sessions if we have them
        final currentWaitingSessions =
            state is WaiterSessionsLoaded
                ? (state as WaiterSessionsLoaded).waitingSessions
                : <WaiterSessionEntity>[];

        emit(
          WaiterSessionsLoaded(
            waitingSessions: currentWaitingSessions,
            activeSessions: activeSessions,
          ),
        );
      },
    );
  }

  Future<void> _onJoinSession(
    JoinSessionEvent event,
    Emitter<WaiterState> emit,
  ) async {
    emit(WaiterLoading());

    final result = await joinSession(
      JoinSessionParams(
        tableId: event.tableId,
        waiterId: event.waiterId,
        waiterName: event.waiterName,
      ),
    );

    result.fold(
      (failure) {
        emit(WaiterError(failure.message));
      },
      (session) {
        emit(SessionJoined(session));
      },
    );
  }

  Future<void> _onEndSession(
    EndSessionEvent event,
    Emitter<WaiterState> emit,
  ) async {
    emit(WaiterLoading());

    final result = await endSession(
      EndSessionParams(sessionId: event.sessionId),
    );

    result.fold(
      (failure) {
        emit(WaiterError(failure.message));
      },
      (_) {
        emit(const SessionEnded('Session completed successfully'));
      },
    );
  }

  Future<void> _onRefreshSessions(
    RefreshSessionsEvent event,
    Emitter<WaiterState> emit,
  ) async {
    // Load both waiting and active sessions
    final waitingResult = await getWaitingSessions(
      GetWaitingSessionsParams(restaurantId: event.restaurantId),
    );

    final activeResult = await getWaiterActiveSessions(
      GetWaiterActiveSessionsParams(waiterId: event.waiterId),
    );

    // Combine results
    final waitingSessions = waitingResult.fold(
      (_) => <WaiterSessionEntity>[],
      (sessions) => sessions,
    );

    final activeSessions = activeResult.fold(
      (_) => <WaiterSessionEntity>[],
      (sessions) => sessions,
    );

    emit(
      WaiterSessionsLoaded(
        waitingSessions: waitingSessions,
        activeSessions: activeSessions,
      ),
    );
  }
}
