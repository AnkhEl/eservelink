import 'package:eservelink/core/util/snack_bar_util.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_event.dart';
import 'package:eservelink/features/auth/presentation/pages/email_verification_page.dart';
import 'package:eservelink/features/auth/presentation/pages/password_reset_page.dart';
import 'package:eservelink/features/auth/presentation/pages/register_page.dart';
import 'package:eservelink/features/home/presentation/widgets/home_wrapper.dart';
import 'package:eservelink/features/sessions/presentation/bloc/session_bloc.dart';
import 'package:eservelink/features/sessions/presentation/bloc/session_state.dart';
import 'package:eservelink/features/sessions/presentation/pages/session_active_page.dart';
import 'package:eservelink/features/sessions/presentation/pages/session_waiting_page.dart';
import 'package:eservelink/features/waiter/presentation/widgets/waiter_home_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';
import 'package:eservelink/features/auth/presentation/pages/login_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isOnRegisterPage = false;
  bool _showSuccessSnackbar = false;

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in when wrapper initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = context.read<AuthBloc>().state;
      if (currentState is! AuthSuccess) {
        context.read<AuthBloc>().add(const GetCurrentUserEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBarUtils.error(title: "Oops", message: state.message),
          );
        }

        if (state is AuthShowLogin) {
          _isOnRegisterPage = false;
          _showSuccessSnackbar = true;
        } else if (state is AuthShowRegister) {
          _isOnRegisterPage = true;
          _showSuccessSnackbar = false;
        } else if (state is AuthSuccess) {
          // Show success snackbar when navigating to home
          if (_showSuccessSnackbar) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBarUtils.success(
                title: "Success",
                message: "You have successfully logged in",
              ),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
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

        if (state is EmailVerificationSent) {
          return EmailVerificationPage(email: state.email);
        }

        if (state is EmailVerificationLoading) {
          return const EmailVerificationPage();
        }

        if (state is EmailVerificationFailure) {
          return const EmailVerificationPage();
        }

        if (state is AuthEmailNotVerified) {
          return EmailVerificationPage(email: state.user.email);
        }

        if (state is AuthFailure) {
          return _isOnRegisterPage ? const RegisterPage() : const LoginPage();
        }

        if (state is AuthSuccess) {
          final user = state.user;

          if (user.role == 'company_user') {
            return WaiterHomeWrapper();
          }

          if (user.role == 'admin') {
            /// TODO: We wilL return an AdminHomeWrapper()
          }

          return BlocBuilder<SessionBloc, SessionState>(
            builder: (context, sessionState) {
              // Show session waiting page
              if (sessionState is SessionShowWaiting) {
                return SessionWaitingPage(session: sessionState.session);
              }

              // Show session active page
              if (sessionState is SessionShowActive) {
                return SessionActivePage(session: sessionState.session);
              }

              if(sessionState is SessionShowHome){
                return const HomeWrapper();
              }

              // Default: Show home wrapper
              return const HomeWrapper();
            },
          );
        }

        return const LoginPage();
      },
    );
  }
}
