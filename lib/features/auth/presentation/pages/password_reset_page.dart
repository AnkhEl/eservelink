import 'package:eservelink/core/util/auth_validator.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_event.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';
import 'package:eservelink/features/auth/presentation/components/my_button.dart';
import 'package:eservelink/features/auth/presentation/components/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _onResetPasswordPressed() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      context.read<AuthBloc>().add(ResetPasswordEvent(email: email));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.grey[300],
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ResetPasswordFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ResetPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password reset email sent to ${state.email}'),
                backgroundColor: Colors.green,
              ),
            );

            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                context.read<AuthBloc>().add(ShowLoginPageEvent());
              }
            });
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),

                      // logo
                      const Icon(Icons.lock, size: 100),

                      const SizedBox(height: 50),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          'Please enter your email, we will send you a link to reset your password if your account exists.',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 25),

                      MyTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        obscureText: false,
                        validator: AuthValidator.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                      ),

                      const SizedBox(height: 30),

                      MyButton(
                        onTap: _onResetPasswordPressed,
                        title: 'Reset Password',
                      ),
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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
