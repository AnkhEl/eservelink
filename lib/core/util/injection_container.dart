import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/auth/data/repositories/user_repository_impl.dart';
import 'package:eservelink/features/auth/domain/repositories/user_repository.dart';
import 'package:eservelink/features/auth/domain/usecases/check_email_verification.dart';
import 'package:eservelink/features/auth/domain/usecases/reset_password.dart';
import 'package:eservelink/features/auth/domain/usecases/send_email_verification.dart';
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
import 'package:eservelink/features/qr_scanner/data/repositories/qr_scanner_repository_impl.dart';
import 'package:eservelink/features/qr_scanner/domain/repositories/qr_scanner_repository.dart';
import 'package:eservelink/features/qr_scanner/domain/usecases/scan_qr_code.dart';
import 'package:eservelink/features/sessions/data/datasources/chat_remote_data_source.dart';
import 'package:eservelink/features/sessions/data/datasources/ping_remote_data_source.dart';
import 'package:eservelink/features/sessions/data/datasources/session_remote_data_source.dart';
import 'package:eservelink/features/sessions/data/datasources/table_remote_data_source.dart';
import 'package:eservelink/features/sessions/data/repositories/chat_repository_impl.dart';
import 'package:eservelink/features/sessions/data/repositories/ping_repository_impl.dart';
import 'package:eservelink/features/sessions/data/repositories/session_repository_impl.dart';
import 'package:eservelink/features/sessions/data/repositories/table_repository_impl.dart';
import 'package:eservelink/features/sessions/domain/repositories/chat_repository.dart';
import 'package:eservelink/features/sessions/domain/repositories/ping_repository.dart';
import 'package:eservelink/features/sessions/domain/repositories/session_repository.dart';
import 'package:eservelink/features/sessions/domain/repositories/table_repository.dart';
import 'package:eservelink/features/sessions/domain/usecases/get_active_session_usecase.dart';
import 'package:eservelink/features/sessions/domain/usecases/get_user_sessions_usecase.dart';
import 'package:eservelink/features/sessions/domain/usecases/join_session_as_waiter_usecase.dart';
import 'package:eservelink/features/sessions/domain/usecases/scan_qr_and_create_session_usecase.dart';
import 'package:eservelink/features/sessions/domain/usecases/send_chat_message_usecase.dart';
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

  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<PingRemoteDataSource>(
    () => PingRemoteDataSourceImpl(firestore: sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<WaiterRemoteDataSource>(
    () => WaiterRemoteDataSourceImpl(firestore: sl<FirebaseFirestore>()),
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

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<PingRepository>(
    () => PingRepositoryImpl(remoteDataSource: sl<PingRemoteDataSource>()),
  );

  sl.registerLazySingleton<WaiterRepository>(
    () => WaiterRepositoryImpl(remoteDataSource: sl<WaiterRemoteDataSource>()),
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

  sl.registerLazySingleton<SendChatMessageUseCase>(
    () => SendChatMessageUseCase(repository: sl()),
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

  sl.registerLazySingleton(() => GetWaitingSessionsUseCase(sl()));
  sl.registerLazySingleton(() => GetWaiterActiveSessionsUseCase(sl()));
  sl.registerLazySingleton(() => JoinSessionUseCase(sl()));
  sl.registerLazySingleton(() => EndSessionUseCase(sl()));

  //Blocs

  sl.registerFactory<WaiterBloc>(
    () => WaiterBloc(
      getWaitingSessions: sl(),
      getWaiterActiveSessions: sl(),
      joinSession: sl(),
      endSession: sl(),
    ),
  );
  // TODO: Add other core service registrations (like network checker, local storage, etc.) here as needed
}
