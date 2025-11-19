import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eservelink/features/notifications/domain/entities/notification_entity.dart';
import 'package:eservelink/features/notifications/domain/usecases/create_notification_usecase.dart';
import 'package:eservelink/features/notifications/domain/usecases/stream_notifications_usecase.dart';
import 'package:eservelink/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:eservelink/features/notifications/domain/usecases/mark_all_read_usecase.dart';
import 'package:eservelink/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:eservelink/features/notifications/presentation/bloc/notification_event.dart';
import 'package:eservelink/features/notifications/presentation/bloc/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final StreamNotificationsUseCase streamNotifications;
  final CreateNotificationUseCase createNotification;
  final MarkNotificationReadUseCase markNotificationRead;
  final MarkAllReadUseCase markAllRead;
  final DeleteNotificationUseCase deleteNotification;

  StreamSubscription? _notificationsSubscription;
  List<NotificationEntity> _currentNotifications = [];

  NotificationBloc({
    required this.streamNotifications,
    required this.createNotification,
    required this.markNotificationRead,
    required this.markAllRead,
    required this.deleteNotification,
  }) : super(NotificationInitial()) {
    on<StartListeningToNotificationsEvent>(_onStartListening);
    on<StopListeningToNotificationsEvent>(_onStopListening);
    on<NotificationsUpdatedEvent>(_onNotificationsUpdated);
    on<CreateNotificationEvent>(_onCreateNotification);
    on<MarkNotificationReadEvent>(_onMarkNotificationRead);
    on<MarkAllNotificationsReadEvent>(_onMarkAllNotificationsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
  }

  Future<void> _onStartListening(
    StartListeningToNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    print('🔔 Starting to listen to notifications for user: ${event.userId}');

    await _notificationsSubscription?.cancel();

    _notificationsSubscription = streamNotifications(event.userId).listen((
      result,
    ) {
      result.fold(
        (failure) {
          print('❌ Error streaming notifications: ${failure.message}');
          add(
            const NotificationsUpdatedEvent(notifications: [], unreadCount: 0),
          );
        },
        (notifications) {
          print('✅ Notifications updated: ${notifications.length}');
          _currentNotifications = notifications;
          final unreadCount = notifications.where((n) => !n.isRead).length;
          add(
            NotificationsUpdatedEvent(
              notifications: notifications,
              unreadCount: unreadCount,
            ),
          );
        },
      );
    });
  }

  void _onStopListening(
    StopListeningToNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) {
    print('⏹️ Stopping notification listeners...');
    _notificationsSubscription?.cancel();
    _notificationsSubscription = null;
  }

  void _onNotificationsUpdated(
    NotificationsUpdatedEvent event,
    Emitter<NotificationState> emit,
  ) {
    emit(
      NotificationsLoaded(
        notifications: event.notifications,
        unreadCount: event.unreadCount,
      ),
    );
  }

  Future<void> _onCreateNotification(
    CreateNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    print('🔔 Creating notification: ${event.title}');

    final result = await createNotification(
      CreateNotificationParams(
        userId: event.userId,
        type: event.type,
        title: event.title,
        body: event.body,
        data: event.data,
        actionUrl: event.actionUrl,
      ),
    );

    result.fold(
      (failure) {
        print('❌ Failed to create notification: ${failure.message}');
      },
      (notification) {
        print('✅ Notification created successfully');
      },
    );
  }

  Future<void> _onMarkNotificationRead(
    MarkNotificationReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    print('📖 Marking notification as read: ${event.notificationId}');

    await markNotificationRead(event.notificationId);
  }

  Future<void> _onMarkAllNotificationsRead(
    MarkAllNotificationsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    print('📖 Marking all notifications as read for user: ${event.userId}');

    await markAllRead(event.userId);
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    print('🗑️ Deleting notification: ${event.notificationId}');

    await deleteNotification(event.notificationId);
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}
