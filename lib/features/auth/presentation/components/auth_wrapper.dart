import 'package:eservelink/features/auth/presentation/pages/password_reset_page.dart';
import 'package:eservelink/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';
import 'package:eservelink/features/auth/presentation/pages/login_page.dart';
import 'package:eservelink/features/auth/presentation/pages/home_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isOnRegisterPage = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }

        if (state is AuthShowLogin) {
          _isOnRegisterPage = false;
        } else if (state is AuthShowRegister) {
          _isOnRegisterPage = true;
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthSuccess) {
          return const HomePage();
        }

        if (state is AuthShowRegister) {
          return const RegisterPage();
        }

        if (state is AuthShowLogin) {
          return const LoginPage();
        }

        if (state is AuthShowPasswordReset) {
          return PasswordResetPage();
        }

        if (state is ResetPasswordSuccess) {
          return PasswordResetPage();
        }

        if (state is ResetPasswordLoading) {
          return const PasswordResetPage();
        }

        if (state is ResetPasswordSuccess) {
          return const PasswordResetPage();
        }

        if (state is ResetPasswordFailure) {
          return const PasswordResetPage();
        }

        if (state is AuthFailure) {
          return _isOnRegisterPage ? const RegisterPage() : const LoginPage();
        }

        return const LoginPage();
      },
    );
  }
}
