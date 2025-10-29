import 'package:eservelink/features/sessions/domain/entities/session_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eservelink/features/sessions/domain/usecases/scan_qr_and_create_session_usecase.dart';
import 'package:eservelink/features/sessions/domain/usecases/get_active_session_usecase.dart';
import 'package:eservelink/features/sessions/domain/usecases/send_ping_usecase.dart';
import 'package:eservelink/features/sessions/domain/repositories/session_repository.dart';
import 'package:eservelink/features/sessions/presentation/bloc/session_event.dart';
import 'package:eservelink/features/sessions/presentation/bloc/session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final ScanQrAndCreateSessionUseCase scanQrAndCreateSession;
  final GetActiveSessionUseCase getActiveSession;
  final SendPingUseCase sendPing;
  final SessionRepository sessionRepository;

  SessionBloc({
    required this.scanQrAndCreateSession,
    required this.getActiveSession,
    required this.sendPing,
    required this.sessionRepository,
  }) : super(SessionInitial()) {
    on<CreateSessionEvent>(_onCreateSession);
    on<LoadActiveSessionEvent>(_onLoadActiveSession);
    on<SendPingEvent>(_onSendPing);
    on<CancelSessionEvent>(_onCancelSession);
    on<ShowSessionWaitingEvent>(_onShowSessionWaiting);
    on<ShowSessionActiveEvent>(_onShowSessionActive);
    on<ShowSessionHomeEvent>(_onShowSessionHome);
  }

  Future<void> _onCreateSession(
    CreateSessionEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionCreating(event.tableId));

    final result = await scanQrAndCreateSession(
      ScanQrAndCreateSessionParams(
        scannedQrCode: event.tableId,
        customerId: event.customerId,
        customerName: event.customerName,
      ),
    );

    result.fold((failure) => emit(SessionError(failure.message)), (session) {
      // Check session status
      if (session.status == SessionStatus.waitingForWaiter) {
        emit(SessionWaitingForWaiter(session));
      } else if (session.status == SessionStatus.active) {
        emit(SessionActive(session));
      } else {
        emit(SessionCreated(session));
      }
    });
  }

  Future<void> _onLoadActiveSession(
    LoadActiveSessionEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());

    final result = await getActiveSession(
      GetActiveSessionParams(customerId: event.customerId),
    );

    result.fold((failure) => emit(SessionError(failure.message)), (session) {
      if (session == null) {
        emit(NoActiveSession());
      } else {
        // Emit appropriate state based on session status
        if (session.status == SessionStatus.waitingForWaiter) {
          emit(SessionWaitingForWaiter(session));
        } else if (session.status == SessionStatus.active) {
          emit(SessionActive(session));
        } else {
          emit(SessionCreated(session));
        }
      }
    });
  }

  Future<void> _onSendPing(
    SendPingEvent event,
    Emitter<SessionState> emit,
  ) async {
    // Get current session to maintain state
    final currentState = state;
    SessionEntity? currentSession;

    if (currentState is SessionActive) {
      currentSession = currentState.session;
    } else if (currentState is SessionWaitingForWaiter) {
      currentSession = currentState.session;
    }

    final result = await sendPing(
      SendPingParams(
        sessionId: event.sessionId,
        customerId: event.customerId,
        customerName: event.customerName,
        tableNumber: event.tableNumber,
        message: event.message,
      ),
    );

    result.fold((failure) => emit(SessionError(failure.message)), (_) {
      if (currentSession != null) {
        emit(PingSent(currentSession));
        // Restore previous state after showing ping confirmation
        Future.delayed(const Duration(milliseconds: 500), () {
          if (currentSession!.status == SessionStatus.active) {
            emit(SessionActive(currentSession));
          } else {
            emit(SessionWaitingForWaiter(currentSession));
          }
        });
      }
    });
  }

  Future<void> _onCancelSession(
    CancelSessionEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());

    final result = await sessionRepository.cancelSession(event.sessionId);

    result.fold(
      (failure) => emit(SessionError(failure.message)),
      (_) => emit(NoActiveSession()),
    );
  }

  void _onShowSessionWaiting(
      ShowSessionWaitingEvent event,
      Emitter<SessionState> emit,
      ) {
    emit(SessionShowWaiting(event.session));
  }

  void _onShowSessionActive(
      ShowSessionActiveEvent event,
      Emitter<SessionState> emit,
      ) {
    emit(SessionShowActive(event.session));
  }

  void _onShowSessionHome(
      ShowSessionHomeEvent event,
      Emitter<SessionState> emit,
      ) {
    emit(SessionShowHome());
  }
}
