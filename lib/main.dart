import 'package:eservelink/features/auth/presentation/pages/login_page.dart';
import 'package:eservelink/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:eservelink/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      home: isOnboarded ? LoginPage() : OnboardingPage(),
    );
  }
}
