import 'package:flutter/material.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            final userName =
                state.user.displayName ??
                state.user.email.split('@')[0] ??
                'User';

            return Center(
              child: Text(
                "Welcome, Mr. $userName! You are on the History Page",
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
