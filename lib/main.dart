import 'package:eservelink/features/auth/domain/usecases/check_email_verification.dart';
import 'package:eservelink/features/auth/domain/usecases/get_current_user.dart';
import 'package:eservelink/features/auth/domain/usecases/register_with_email.dart';
import 'package:eservelink/features/auth/domain/usecases/reset_password.dart';
import 'package:eservelink/features/auth/domain/usecases/send_email_verification.dart';
import 'package:eservelink/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:eservelink/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:eservelink/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:eservelink/features/auth/domain/usecases/sign_out.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_event.dart';
import 'package:eservelink/features/auth/presentation/components/auth_wrapper.dart';
import 'package:eservelink/features/history/presentation/bloc/history_bloc.dart';
import 'package:eservelink/features/home/domain/usecases/add_restaurant_usecase.dart';
import 'package:eservelink/features/home/domain/usecases/get_nearby_restaurants_usecase.dart';
import 'package:eservelink/features/home/domain/usecases/get_restaurant_by_id_usecase.dart';
import 'package:eservelink/features/home/presentation/bloc/restaurant_bloc.dart';
import 'package:eservelink/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:eservelink/features/qr_scanner/presentation/bloc/qr_scanner_bloc.dart';
import 'package:eservelink/features/sessions/domain/repositories/session_repository.dart';
import 'package:eservelink/features/sessions/domain/usecases/get_active_session_usecase.dart';
import 'package:eservelink/features/sessions/domain/usecases/get_user_sessions_usecase.dart';
import 'package:eservelink/features/sessions/domain/usecases/scan_qr_and_create_session_usecase.dart';
import 'package:eservelink/features/sessions/domain/usecases/send_ping_usecase.dart';
import 'package:eservelink/features/sessions/presentation/bloc/session_bloc.dart';
import 'package:eservelink/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:eservelink/core/util/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();
  final sharedPref = await SharedPreferences.getInstance();
  final isOnboarded = sharedPref.getBool('isOnboarded') ?? false;
  runApp(MyApp(isOnboarded: isOnboarded));
}

class MyApp extends StatelessWidget {
  final bool isOnboarded;

  const MyApp({super.key, this.isOnboarded = false});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create:
              (_) => AuthBloc(
                registerWithEmail: di.sl<RegisterWithEmail>(),
                signInWithEmail: di.sl<SignInWithEmail>(),
                signInWithGoogle: di.sl<SignInWithGoogle>(),
                signInWithApple: di.sl<SignInWithApple>(),
                getCurrentUser: di.sl<GetCurrentUser>(),
                signOut: di.sl<SignOut>(),
                resetPassword: di.sl<ResetPassword>(),
                checkEmailVerification: di.sl<CheckEmailVerification>(),
                sendEmailVerification: di.sl<SendEmailVerification>(),
              ),
        ),
        BlocProvider<QrScannerBloc>(
          create: (_) => QrScannerBloc(repository: di.sl()),
        ),
        BlocProvider<RestaurantBloc>(
          create:
              (_) => RestaurantBloc(
                getNearbyRestaurantsUseCase:
                    di.sl<GetNearbyRestaurantsUseCase>(),
                getRestaurantByIdUseCase: di.sl<GetRestaurantByIdUseCase>(),
                addRestaurantUseCase: di.sl<AddRestaurantUseCase>(),
              ),
        ),
        BlocProvider<SessionBloc>(
          create:
              (_) => SessionBloc(
                scanQrAndCreateSession: di.sl<ScanQrAndCreateSessionUseCase>(),
                getActiveSession: di.sl<GetActiveSessionUseCase>(),
                sendPing: di.sl<SendPingUseCase>(),
                sessionRepository: di.sl<SessionRepository>(),
              ),
        ),
        BlocProvider<HistoryBloc>(
          create:
              (_) =>
                  HistoryBloc(getUserSessions: di.sl<GetUserSessionsUseCase>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EServeLink',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: isOnboarded ? const AuthWrapper() : const OnboardingPage(),
      ),
    );
  }
}
