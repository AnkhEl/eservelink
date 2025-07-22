import 'package:eservelink/core/util/auth_validator.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_event.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';
import 'package:eservelink/features/auth/presentation/components/my_button.dart';
import 'package:eservelink/features/auth/presentation/components/my_textfield.dart';
import 'package:eservelink/features/auth/presentation/components/square_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _onRegisterPressed() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final name = _fullNameController.text.trim();

      context.read<AuthBloc>().add(
        RegisterWithEmailEvent(email: email, password: password, name: name),
      );
    }
  }

  void _onGoogleSignInPressed() {
    context.read<AuthBloc>().add(const SignInWithGoogleEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Registration Successful")),
            );
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

                      Text(
                        'Welcome, Please register below!',
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      ),

                      const SizedBox(height: 25),

                      MyTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        obscureText: false,
                        validator: AuthValidator.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 10),

                      MyTextField(
                        controller: _fullNameController,
                        hintText: 'Full Name',
                        obscureText: false,
                        validator:
                            (value) => AuthValidator.validateNotEmpty(
                              value,
                              "Full Name",
                            ),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 10),

                      MyTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: true,
                        validator: AuthValidator.validatePassword,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 10),

                      MyTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirm Password',
                        obscureText: true,
                        validator:
                            (value) => AuthValidator.validateConfirmPassword(
                              _passwordController.text,
                              value,
                            ),
                        textInputAction: TextInputAction.done,
                      ),

                      const SizedBox(height: 15),

                      MyButton(onTap: _onRegisterPressed, title: 'Register'),

                      const SizedBox(height: 20),

                      // or continue with
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey[400],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: Text(
                                'Or continue with',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 50),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // google button
                          SquareTile(
                            imagePath: 'assets/google.png',
                            onTap: _onGoogleSignInPressed,
                          ),

                          SizedBox(width: 25),

                          // apple button
                          SquareTile(
                            imagePath: 'assets/apple.png',
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already a member?',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap:
                                () => context.read<AuthBloc>().add(
                                  ShowLoginPageEvent(),
                                ),
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
