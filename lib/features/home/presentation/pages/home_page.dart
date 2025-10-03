import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_event.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(const SignOutEvent());
            },
            icon: Icon(Icons.logout, size: 30, color: Colors.black),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            final userName =
                state.user.displayName ??
                state.user.email?.split('@')[0] ??
                'User';

            return Center(
              child: Text(
                "Welcome, Mr. $userName!",
                style: const TextStyle(fontSize: 30),
              ),
            );
          }
          return Center(
            child: Text("Welcome:", style: TextStyle(fontSize: 30)),
          );
        },
      ),
    );
  }
}
