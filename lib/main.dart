import 'dart:async';
import 'dart:io';

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
import 'package:eservelink/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:eservelink/features/history/presentation/bloc/history_bloc.dart';
import 'package:eservelink/features/home/domain/usecases/add_restaurant_usecase.dart';
import 'package:eservelink/features/home/domain/usecases/get_nearby_restaurants_usecase.dart';
import 'package:eservelink/features/home/domain/usecases/get_restaurant_by_id_usecase.dart';
import 'package:eservelink/features/home/presentation/bloc/restaurant_bloc.dart';
import 'package:eservelink/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:eservelink/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:eservelink/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:eservelink/features/orders/presentation/bloc/cart/cart_bloc.dart';
import 'package:eservelink/features/orders/presentation/bloc/order/order_bloc.dart';
import 'package:eservelink/features/qr_scanner/presentation/bloc/qr_scanner_bloc.dart';
import 'package:eservelink/features/sessions/domain/repositories/session_repository.dart';
import 'package:eservelink/features/sessions/domain/usecases/get_active_session_usecase.dart';
import 'package:eservelink/features/sessions/domain/usecases/get_user_sessions_usecase.dart';
import 'package:eservelink/features/sessions/domain/usecases/scan_qr_and_create_session_usecase.dart';
import 'package:eservelink/features/sessions/domain/usecases/send_ping_usecase.dart';
import 'package:eservelink/features/sessions/presentation/bloc/session_bloc.dart';
import 'package:eservelink/features/waiter/presentation/bloc/waiter_bloc.dart';
import 'package:eservelink/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:eservelink/core/util/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:newrelic_mobile/config.dart';
import 'package:newrelic_mobile/newrelic_navigation_observer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';

void main() async {
  runZonedGuarded(
    () async {
      // Initialize bindings inside the zone
      WidgetsFlutterBinding.ensureInitialized();

      // Set up Flutter error handling for New Relic
      FlutterError.onError = NewrelicMobile.onError;

      // Load environment variables
      await dotenv.load(fileName: ".env");

      String accessToken = "";

      if (Platform.isAndroid) {
        accessToken = dotenv.env['NEWRELIC_ANDROID_TOKEN'] ?? "";
      } else if (Platform.isIOS) {
        accessToken = dotenv.env['NEWRELIC_IOS_TOKEN'] ?? "";
      }

      if (accessToken.isEmpty) {
        throw Exception(
          'New Relic access token not found. '
          'Please ensure .env file exists with NEWRELIC_ANDROID_TOKEN and NEWRELIC_IOS_TOKEN',
        );
      }

      Config config = Config(
        accessToken: accessToken,
        analyticsEventEnabled: true,
        webViewInstrumentation: true,
        networkErrorRequestEnabled: true,
        networkRequestEnabled: true,
        crashReportingEnabled: true,
        interactionTracingEnabled: true,
        httpResponseBodyCaptureEnabled: true,
        loggingEnabled: true,
        printStatementAsEventsEnabled: true,
        httpInstrumentationEnabled: true,
        distributedTracingEnabled: true,
      );

      // Start New Relic agent using startAgent instead of start
      await NewrelicMobile.instance.startAgent(config);

      // Initialize Firebase and other services
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await di.init();

      final sharedPref = await SharedPreferences.getInstance();
      final isOnboarded = sharedPref.getBool('isOnboarded') ?? false;

      runApp(MyApp(isOnboarded: isOnboarded));
    },
    (Object error, StackTrace stackTrace) {
      // Catch any errors that occur outside of Flutter's error handling
      NewrelicMobile.instance.recordError(error, stackTrace);
    },
  );
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
        BlocProvider<WaiterBloc>(create: (_) => di.sl<WaiterBloc>()),
        BlocProvider<ChatBloc>(create: (_) => di.sl<ChatBloc>()),
        BlocProvider<NotificationBloc>(
          create: (_) => di.sl<NotificationBloc>(),
        ),
        BlocProvider(create: (_) => di.sl<MenuBloc>()),
        BlocProvider(create: (_) => di.sl<CartBloc>()),
        BlocProvider(create: (_) => di.sl<OrderBloc>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EServeLink',
        navigatorObservers: [NewRelicNavigationObserver()],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: isOnboarded ? const AuthWrapper() : const OnboardingPage(),
      ),
    );
  }
}
