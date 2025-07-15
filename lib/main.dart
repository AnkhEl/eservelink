import 'package:eservelink/features/auth/domain/usecases/get_current_user.dart';
import 'package:eservelink/features/auth/domain/usecases/register_with_email.dart';
import 'package:eservelink/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:eservelink/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:eservelink/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:eservelink/features/auth/domain/usecases/sign_out.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/pages/login_page.dart';
import 'package:eservelink/features/auth/presentation/pages/register_page.dart';
import 'package:eservelink/features/onboarding/presentation/pages/onboarding_page.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EServeLink',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MultiBlocProvider(
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
                ),
          ),
        ],
        child: isOnboarded ? const RegisterPage() : const OnboardingPage(),
      ),
    );
  }
}
