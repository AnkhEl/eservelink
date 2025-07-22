import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class RegisterWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const RegisterWithEmailEvent({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class SignInWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignInWithGoogleEvent extends AuthEvent {
  const SignInWithGoogleEvent();
}

class SignInWithAppleEvent extends AuthEvent {
  const SignInWithAppleEvent();
}

class GetCurrentUserEvent extends AuthEvent {
  const GetCurrentUserEvent();
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

class ResetPasswordEvent extends AuthEvent {
  final String email;

  const ResetPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class ShowLoginPageEvent extends AuthEvent {
  const ShowLoginPageEvent();
}

class ShowRegisterPageEvent extends AuthEvent {
  const ShowRegisterPageEvent();
}

class ShowResetPasswordPageEvent extends AuthEvent {
  const ShowResetPasswordPageEvent();
}
