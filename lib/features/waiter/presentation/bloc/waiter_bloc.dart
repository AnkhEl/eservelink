import 'dart:async';
import 'package:eservelink/features/waiter/domain/entities/waiter_session_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eservelink/features/waiter/domain/repositories/waiter_repository.dart';
import 'package:eservelink/features/waiter/domain/usecases/join_session_usecase.dart';
import 'package:eservelink/features/waiter/domain/usecases/end_session_usecase.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_event.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_state.dart';

class WaiterBloc extends Bloc<WaiterEvent, WaiterState> {
  final WaiterRepository repository;
  final JoinSessionUseCase joinSession;
  final EndSessionUseCase endSession;

  // Stream subscriptions for real-time updates
  StreamSubscription? _waitingSessionsSubscription;
  StreamSubscription? _activeSessionsSubscription;

  // Cache current sessions for state transitions
  List<WaiterSessionEntity> _currentWaitingSessions = [];
  List<WaiterSessionEntity> _currentActiveSessions = [];

  WaiterBloc({
    required this.repository,
    required this.joinSession,
    required this.endSession,
  }) : super(WaiterInitial()) {
    on<StartWatchingSessionsEvent>(_onStartWatchingSessions);
    on<StopWatchingSessionsEvent>(_onStopWatchingSessions);
    on<SessionsUpdatedEvent>(_onSessionsUpdated);
    on<JoinSessionEvent>(_onJoinSession);
    on<EndSessionEvent>(_onEndSession);
    on<ShowWaiterSessionEvent>(_onShowWaiterSession);
    on<ShowWaiterHomeEvent>(_onShowWaiterHome);
  }

  Future<void> _onStartWatchingSessions(
    StartWatchingSessionsEvent event,
    Emitter<WaiterState> emit,
  ) async {
    // Cancel existing subscriptions
    await _waitingSessionsSubscription?.cancel();
    await _activeSessionsSubscription?.cancel();

    // Start watching waiting sessions
    _waitingSessionsSubscription = repository
        .watchWaitingSessions(restaurantId: event.restaurantId)
        .listen((result) {
          result.fold(
            (failure) {
              add(
                SessionsUpdatedEvent(
                  waitingSessions: [],
                  activeSessions: _currentActiveSessions,
                ),
              );
            },
            (sessions) {
              _currentWaitingSessions = sessions;
              add(
                SessionsUpdatedEvent(
                  waitingSessions: sessions,
                  activeSessions: _currentActiveSessions,
                ),
              );
            },
          );
        }, onError: (error) {});

    // Start watching active sessions
    _activeSessionsSubscription = repository
        .watchWaiterActiveSessions(waiterId: event.waiterId)
        .listen((result) {
          result.fold(
            (failure) {
              add(
                SessionsUpdatedEvent(
                  waitingSessions: _currentWaitingSessions,
                  activeSessions: [],
                ),
              );
            },
            (sessions) {
              _currentActiveSessions = sessions;
              add(
                SessionsUpdatedEvent(
                  waitingSessions: _currentWaitingSessions,
                  activeSessions: sessions,
                ),
              );
            },
          );
        }, onError: (error) {});
  }

  void _onStopWatchingSessions(
    StopWatchingSessionsEvent event,
    Emitter<WaiterState> emit,
  ) {
    _waitingSessionsSubscription?.cancel();
    _activeSessionsSubscription?.cancel();
    _waitingSessionsSubscription = null;
    _activeSessionsSubscription = null;
  }

  void _onSessionsUpdated(
    SessionsUpdatedEvent event,
    Emitter<WaiterState> emit,
  ) {
    emit(
      WaiterSessionsLoaded(
        waitingSessions: event.waitingSessions,
        activeSessions: event.activeSessions,
      ),
    );
  }

  Future<void> _onJoinSession(
    JoinSessionEvent event,
    Emitter<WaiterState> emit,
  ) async {
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
        // Just emit success - UI will handle it and streams will update
        emit(SessionJoined(session));
      },
    );
  }

  Future<void> _onEndSession(
    EndSessionEvent event,
    Emitter<WaiterState> emit,
  ) async {
    final result = await endSession(
      EndSessionParams(sessionId: event.sessionId),
    );

    result.fold(
      (failure) {
        emit(WaiterError(failure.message));
      },
      (_) {
        // Just emit success - UI will handle it and streams will update
        emit(const SessionEnded('Session completed successfully'));
      },
    );
  }

  @override
  Future<void> close() {
    _waitingSessionsSubscription?.cancel();
    _activeSessionsSubscription?.cancel();
    return super.close();
  }

  FutureOr<void> _onShowWaiterSession(
    ShowWaiterSessionEvent event,
    Emitter<WaiterState> emit,
  ) {
    emit(ShowWaiterSessionPage(event.session));
  }

  FutureOr<void> _onShowWaiterHome(
    ShowWaiterHomeEvent event,
    Emitter<WaiterState> emit,
  ) {
    emit(ShowWaiterHomePage());
  }
}
