import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:eservelink/core/usecases/usecase.dart';

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

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepository(
      firebaseAuth: sl<FirebaseAuth>(),
      googleSignIn: sl<GoogleSignIn>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<SignInWithGoogle>(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton<SignInWithEmail>(() => SignInWithEmail(sl()));
  sl.registerLazySingleton<RegisterWithEmail>(() => RegisterWithEmail(sl()));
  sl.registerLazySingleton<SignInWithApple>(() => SignInWithApple(sl()));
  sl.registerLazySingleton<GetCurrentUser>(() => GetCurrentUser(sl()));
  sl.registerLazySingleton<SignOut>(() => SignOut(sl()));

  // TODO: Add other core service registrations (like network checker, local storage, etc.) here as needed
}
