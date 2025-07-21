import 'package:eservelink/core/util/auth_validator.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_event.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';
import 'package:eservelink/features/auth/presentation/components/my_button.dart';
import 'package:eservelink/features/auth/presentation/components/my_textfield.dart';
import 'package:eservelink/features/auth/presentation/components/square_tile.dart';
import 'package:eservelink/features/auth/presentation/pages/home_page.dart';
import 'package:eservelink/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _onSignInPressed() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      context.read<AuthBloc>().add(
        SignInWithEmailEvent(email: email, password: password),
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Login Successful")));
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
                        'Welcome back, You\'ve been missed!',
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
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: true,
                        validator: AuthValidator.validatePassword,
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 30),

                      MyButton(onTap: _onSignInPressed, title: 'Sign In'),

                      const SizedBox(height: 30),

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
                            'Not a member?',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          // const SizedBox(width: 4),
                          TextButton(
                            onPressed:
                                () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterPage(),
                                  ),
                                ),
                            child: Text(
                              'Register',
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
    _passwordController.dispose();
    super.dispose();
  }
}
