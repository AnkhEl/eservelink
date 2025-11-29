import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/core/services/notification_service.dart';
import 'package:eservelink/features/auth/data/repositories/user_repository_impl.dart';
import 'package:eservelink/features/auth/domain/repositories/user_repository.dart';
import 'package:eservelink/features/auth/domain/usecases/check_email_verification.dart';
import 'package:eservelink/features/auth/domain/usecases/reset_password.dart';
import 'package:eservelink/features/auth/domain/usecases/send_email_verification.dart';
import 'package:eservelink/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:eservelink/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:eservelink/features/chat/domain/repositories/chat_repository.dart';
import 'package:eservelink/features/chat/domain/usecases/mark_messages_read_usecase.dart';
import 'package:eservelink/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:eservelink/features/chat/domain/usecases/send_typing_indicator_usecase.dart';
import 'package:eservelink/features/chat/domain/usecases/stream_messages_usecase.dart';
import 'package:eservelink/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:eservelink/features/home/data/datasources/restaurant_remote_data_source.dart';
import 'package:eservelink/features/home/data/datasources/review_remote_data_source.dart';
import 'package:eservelink/features/home/data/repositories/restaurant_repository_impl.dart';
import 'package:eservelink/features/home/data/repositories/review_repository_impl.dart';
import 'package:eservelink/features/home/domain/repositories/restaurant_repository.dart';
import 'package:eservelink/features/home/domain/repositories/review_repository.dart';
import 'package:eservelink/features/home/domain/usecases/add_restaurant_usecase.dart';
import 'package:eservelink/features/home/domain/usecases/get_average_rating_usecase.dart';
import 'package:eservelink/features/home/domain/usecases/get_nearby_restaurants_usecase.dart';
import 'package:eservelink/features/home/domain/usecases/get_rating_breakdown_usecase.dart';
import 'package:eservelink/features/home/domain/usecases/get_restaurant_by_id_usecase.dart';
import 'package:eservelink/features/home/domain/usecases/get_restaurant_reviews_usecase.dart';
import 'package:eservelink/features/menu/data/datasources/menu_remote_data_source.dart';
import 'package:eservelink/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:eservelink/features/menu/domain/repositories/menu_repository.dart';
import 'package:eservelink/features/menu/domain/usecases/get_categories_usecase.dart';
import 'package:eservelink/features/menu/domain/usecases/get_menu_item_usecase.dart';
import 'package:eservelink/features/menu/domain/usecases/get_menu_items_by_category_usecase.dart';
import 'package:eservelink/features/menu/domain/usecases/get_menu_items_usecase.dart';
import 'package:eservelink/features/menu/domain/usecases/search_menu_items_usecase.dart';
import 'package:eservelink/features/menu/domain/usecases/stream_menu_items_usecase.dart';
import 'package:eservelink/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:eservelink/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:eservelink/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:eservelink/features/notifications/domain/repositories/notification_repository.dart';
import 'package:eservelink/features/notifications/domain/usecases/create_notification_usecase.dart';
import 'package:eservelink/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:eservelink/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:eservelink/features/notifications/domain/usecases/mark_all_read_usecase.dart';
import 'package:eservelink/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:eservelink/features/notifications/domain/usecases/stream_notifications_usecase.dart';
import 'package:eservelink/features/notifications/domain/usecases/stream_unread_notifications_usecase.dart';
import 'package:eservelink/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:eservelink/features/qr_scanner/data/repositories/qr_scanner_repository_impl.dart';
import 'package:eservelink/features/qr_scanner/domain/repositories/qr_scanner_repository.dart';
import 'package:eservelink/features/qr_scanner/domain/usecases/scan_qr_code.dart';
import 'package:eservelink/features/sessions/data/datasources/ping_remote_data_source.dart';
import 'package:eservelink/features/sessions/data/datasources/session_remote_data_source.dart';
import 'package:eservelink/features/sessions/data/datasources/table_remote_data_source.dart';
import 'package:eservelink/features/sessions/data/repositories/ping_repository_impl.dart';
import 'package:eservelink/features/sessions/data/repositories/session_repository_impl.dart';
import 'package:eservelink/features/sessions/data/repositories/table_repository_impl.dart';
import 'package:eservelink/features/sessions/domain/repositories/ping_repository.dart';
import 'package:eservelink/features/sessions/domain/repositories/session_repository.dart';
import 'package:eservelink/features/sessions/domain/repositories/table_repository.dart';
import 'package:eservelink/features/sessions/domain/usecases/acknowledge_ping_usecase.dart';
import 'package:eservelink/features/sessions/domain/usecases/get_active_session_usecase.dart';
import 'package:eservelink/features/sessions/domain/usecases/get_user_sessions_usecase.dart';
import 'package:eservelink/features/sessions/domain/usecases/join_session_as_waiter_usecase.dart';
import 'package:eservelink/features/sessions/domain/usecases/scan_qr_and_create_session_usecase.dart';
import 'package:eservelink/features/sessions/domain/usecases/send_ping_usecase.dart';
import 'package:eservelink/features/waiter/data/datasources/waiter_remote_data_source.dart';
import 'package:eservelink/features/waiter/data/repositories/waiter_repository_impl.dart';
import 'package:eservelink/features/waiter/domain/repositories/waiter_repository.dart';
import 'package:eservelink/features/waiter/domain/usecases/end_session_usecase.dart';
import 'package:eservelink/features/waiter/domain/usecases/get_waiter_active_sessions_usecase.dart';
import 'package:eservelink/features/waiter/domain/usecases/get_waiting_sessions_usecase.dart';
import 'package:eservelink/features/waiter/domain/usecases/join_session_usecase.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:eservelink/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:eservelink/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:eservelink/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:eservelink/features/auth/domain/usecases/register_with_email.dart';
import 'package:eservelink/features/auth/domain/usecases/get_current_user.dart';
import 'package:eservelink/features/auth/domain/usecases/sign_out.dart';

import 'package:eservelink/features/auth/domain/repositories/auth_repository.dart';
import 'package:eservelink/features/auth/data/repositories/firebase_auth_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Firebase Services
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  //datasources

  sl.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(firestore: sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(firestore: sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<TableRemoteDataSource>(
    () => TableRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<SessionRemoteDataSource>(
    () => SessionRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<PingRemoteDataSource>(
    () => PingRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
      notificationService: sl<NotificationService>(),
    ),
  );

  sl.registerLazySingleton<WaiterRemoteDataSource>(
    () => WaiterRemoteDataSourceImpl(firestore: sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(firestore: sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
      notificationService: sl<NotificationService>(),
    ),
  );

  sl.registerLazySingleton<MenuRemoteDataSource>(
    () => MenuRemoteDataSourceImpl(firestore: sl<FirebaseFirestore>()),
  );

  // Repositories
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(firestore: sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepository(
      firebaseAuth: sl<FirebaseAuth>(),
      googleSignIn: sl<GoogleSignIn>(),
      userRepository: sl<UserRepository>(),
    ),
  );

  sl.registerLazySingleton<QrScannerRepository>(
    () => QrScannerRepositoryImpl(),
  );

  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(
      remoteDataSource: sl<RestaurantRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(remoteDataSource: sl<ReviewRemoteDataSource>()),
  );

  sl.registerLazySingleton<TableRepository>(
    () => TableRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<PingRepository>(
    () => PingRepositoryImpl(remoteDataSource: sl<PingRemoteDataSource>()),
  );

  sl.registerLazySingleton<WaiterRepository>(
    () => WaiterRepositoryImpl(remoteDataSource: sl<WaiterRemoteDataSource>()),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton<SignInWithGoogle>(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton<SignInWithEmail>(() => SignInWithEmail(sl()));
  sl.registerLazySingleton<RegisterWithEmail>(() => RegisterWithEmail(sl()));
  sl.registerLazySingleton<SignInWithApple>(() => SignInWithApple(sl()));
  sl.registerLazySingleton<GetCurrentUser>(() => GetCurrentUser(sl()));
  sl.registerLazySingleton<SignOut>(() => SignOut(sl()));
  sl.registerLazySingleton<ResetPassword>(() => ResetPassword(sl()));
  sl.registerLazySingleton<CheckEmailVerification>(
    () => CheckEmailVerification(sl()),
  );
  sl.registerLazySingleton<SendEmailVerification>(
    () => SendEmailVerification(sl()),
  );
  sl.registerLazySingleton<ScanQrCode>(
    () => ScanQrCode(sl<QrScannerRepository>()),
  );

  sl.registerLazySingleton<GetNearbyRestaurantsUseCase>(
    () => GetNearbyRestaurantsUseCase(repository: sl<RestaurantRepository>()),
  );

  sl.registerLazySingleton<GetRestaurantByIdUseCase>(
    () => GetRestaurantByIdUseCase(repository: sl<RestaurantRepository>()),
  );

  sl.registerLazySingleton<AddRestaurantUseCase>(
    () => AddRestaurantUseCase(repository: sl<RestaurantRepository>()),
  );

  sl.registerLazySingleton<GetRestaurantReviewsUseCase>(
    () => GetRestaurantReviewsUseCase(repository: sl<ReviewRepository>()),
  );

  sl.registerLazySingleton<GetAverageRatingUseCase>(
    () => GetAverageRatingUseCase(repository: sl<ReviewRepository>()),
  );

  sl.registerLazySingleton<GetRatingBreakdownUseCase>(
    () => GetRatingBreakdownUseCase(repository: sl<ReviewRepository>()),
  );

  sl.registerLazySingleton<ScanQrAndCreateSessionUseCase>(
    () => ScanQrAndCreateSessionUseCase(
      tableRepository: sl(),
      sessionRepository: sl(),
    ),
  );

  sl.registerLazySingleton<JoinSessionAsWaiterUseCase>(
    () => JoinSessionAsWaiterUseCase(
      sessionRepository: sl(),
      tableRepository: sl(),
    ),
  );

  sl.registerLazySingleton<GetActiveSessionUseCase>(
    () => GetActiveSessionUseCase(repository: sl()),
  );

  sl.registerLazySingleton<SendPingUseCase>(
    () => SendPingUseCase(
      pingRepository: sl<PingRepository>(),
      sessionRepository: sl<SessionRepository>(),
    ),
  );
  sl.registerLazySingleton<GetUserSessionsUseCase>(
    () => GetUserSessionsUseCase(repository: sl<SessionRepository>()),
  );

  sl.registerLazySingleton(
    () => GetWaitingSessionsUseCase(sl<WaiterRepository>()),
  );
  sl.registerLazySingleton(
    () => GetWaiterActiveSessionsUseCase(sl<WaiterRepository>()),
  );
  sl.registerLazySingleton(() => JoinSessionUseCase(sl<WaiterRepository>()));
  sl.registerLazySingleton(() => EndSessionUseCase(sl<WaiterRepository>()));

  sl.registerLazySingleton(() => SendMessageUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => StreamMessagesUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => MarkMessagesReadUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(
    () => SendTypingIndicatorUseCase(sl<ChatRepository>()),
  );

  sl.registerLazySingleton(() => CreateNotificationUseCase(sl()));
  sl.registerLazySingleton(() => StreamNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => StreamUnreadNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllReadUseCase(sl()));
  sl.registerLazySingleton(() => GetUnreadCountUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNotificationUseCase(sl()));
  sl.registerLazySingleton(() => AcknowledgePingUseCase(sl()));

  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetMenuItemsUseCase(sl()));
  sl.registerLazySingleton(() => GetMenuItemsByCategoryUseCase(sl()));
  sl.registerLazySingleton(() => SearchMenuItemsUseCase(sl()));
  sl.registerLazySingleton(() => GetMenuItemUseCase(sl()));
  sl.registerLazySingleton(() => StreamMenuItemsUseCase(sl()));

  //Blocs

  sl.registerFactory<WaiterBloc>(
    () => WaiterBloc(
      joinSession: sl<JoinSessionUseCase>(),
      endSession: sl<EndSessionUseCase>(),
      repository: sl<WaiterRepository>(),
      acknowledgePing: sl<AcknowledgePingUseCase>(),
    ),
  );

  sl.registerFactory(
    () => ChatBloc(
      streamMessages: sl<StreamMessagesUseCase>(),
      sendMessage: sl<SendMessageUseCase>(),
      markMessagesRead: sl<MarkMessagesReadUseCase>(),
      sendTypingIndicator: sl<SendTypingIndicatorUseCase>(),
      repository: sl<ChatRepository>(),
    ),
  );

  sl.registerFactory(
    () => NotificationBloc(
      streamNotifications: sl(),
      createNotification: sl(),
      markNotificationRead: sl(),
      markAllRead: sl(),
      deleteNotification: sl(),
    ),
  );

  sl.registerFactory(
    () => MenuBloc(
      getCategories: sl<GetCategoriesUseCase>(),
      getMenuItems: sl<GetMenuItemsUseCase>(),
      getMenuItemsByCategory: sl<GetMenuItemsByCategoryUseCase>(),
      searchMenuItems: sl<SearchMenuItemsUseCase>(),
      getMenuItem: sl<GetMenuItemUseCase>(),
    ),
  );

  // TODO: Add other core service registrations (like network checker, local storage, etc.) here as needed
  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(
      createNotification: sl<CreateNotificationUseCase>(),
    ),
  );
}
