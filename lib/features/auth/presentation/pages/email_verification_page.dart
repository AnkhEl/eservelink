import 'package:eservelink/features/auth/presentation/components/my_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_event.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';
import 'package:eservelink/core/util/snack_bar_util.dart';

class EmailVerificationPage extends StatefulWidget {
  final String? email;

  const EmailVerificationPage({super.key, this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  String? _displayEmail;
  bool _isSendingEmail = false;

  @override
  void initState() {
    super.initState();
    _displayEmail = widget.email;

    if (_displayEmail == null) {
      context.read<AuthBloc>().add(const GetCurrentUserEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(
            onPressed: () => context.read<AuthBloc>().add(const SignOutEvent()),
            icon: const Icon(Icons.logout, size: 30, color: Colors.black),
          ),
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (_displayEmail == null) {
            if (state is AuthEmailNotVerified) {
              setState(() {
                _displayEmail = state.user.email;
              });
            } else if (state is AuthSuccess) {
              setState(() {
                _displayEmail = state.user.email;
              });
            }
          }

          // Reset loading flags when operations complete
          if (state is EmailVerificationFailure ||
              state is EmailVerificationSent ||
              state is AuthSuccess ||
              state is AuthEmailNotVerified) {
            setState(() {
              _isSendingEmail = false;
            });
          }

          if (state is EmailVerificationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBarUtils.error(title: "Error", message: state.message),
            );
          } else if (state is EmailVerificationSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBarUtils.success(
                title: "Email Sent",
                message: "Verification email sent to ${state.email}",
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is EmailVerificationLoading;
          final isCheckingVerification = isLoading && !_isSendingEmail;
          final isSendingEmail = isLoading && _isSendingEmail;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.mark_email_unread,
                        size: 100,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Verify Your Email',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'We have sent you a verification email to:',
                        style: TextStyle(fontSize: 17, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _displayEmail ?? 'Loading email...',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Click the link in your email to verify your account. Once verified, click the button below.',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      MyButton(
                        onTap:
                            isCheckingVerification
                                ? null
                                : () {
                                  context.read<AuthBloc>().add(
                                    const CheckEmailVerificationEvent(),
                                  );
                                },
                        title:
                            isCheckingVerification
                                ? 'Checking...'
                                : 'I\'ve Verified My Email',
                      ),

                      const SizedBox(height: 16),
                      TextButton(
                        onPressed:
                            isLoading && isSendingEmail
                                ? null
                                : () {
                                  setState(() {
                                    _isSendingEmail = true;
                                  });
                                  context.read<AuthBloc>().add(
                                    SendEmailVerificationEvent(
                                      email: _displayEmail!,
                                    ),
                                  );
                                },
                        child: Text(
                          isLoading && isSendingEmail
                              ? 'Sending...'
                              : 'Resend Verification Email',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isLoading) ...[
                        const SizedBox(height: 20),
                        const CircularProgressIndicator(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
