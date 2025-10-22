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
  // TODO: Add other core service registrations (like network checker, local storage, etc.) here as needed
}
