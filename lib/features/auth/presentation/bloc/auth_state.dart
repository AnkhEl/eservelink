import 'package:equatable/equatable.dart';
import 'package:eservelink/features/auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserEntity user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthShowLogin extends AuthState {
  const AuthShowLogin();
}

class AuthShowRegister extends AuthState {
  const AuthShowRegister();
}

class AuthShowPasswordReset extends AuthState {
  const AuthShowPasswordReset();
}

class ResetPasswordLoading extends AuthState {
  const ResetPasswordLoading();
}

class ResetPasswordSuccess extends AuthState {
  final String email;

  const ResetPasswordSuccess({required this.email});

  @override
  List<Object?> get props => [email];
}

class ResetPasswordFailure extends AuthState {
  final String message;

  const ResetPasswordFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
