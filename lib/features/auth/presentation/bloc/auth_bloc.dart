import 'dart:async';

import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/auth/domain/entities/user_entity.dart';
import 'package:eservelink/features/auth/domain/usecases/get_current_user.dart';
import 'package:eservelink/features/auth/domain/usecases/reset_password.dart';
import 'package:eservelink/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:eservelink/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:eservelink/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:eservelink/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eservelink/features/auth/domain/usecases/register_with_email.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_event.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterWithEmail registerWithEmail;
  final SignInWithEmail signInWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final SignInWithApple signInWithApple;
  final GetCurrentUser getCurrentUser;
  final SignOut signOut;
  final ResetPassword resetPassword;

  AuthBloc({
    required this.registerWithEmail,
    required this.signInWithEmail,
    required this.signInWithGoogle,
    required this.signInWithApple,
    required this.getCurrentUser,
    required this.signOut,
    required this.resetPassword,
  }) : super(AuthInitial()) {
    on<RegisterWithEmailEvent>(_onRegisterWithEmail);
    on<SignInWithEmailEvent>(_onSignInWithEmail);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignInWithAppleEvent>(_onSignInWithApple);
    on<GetCurrentUserEvent>(_onGetCurrentUser);
    on<SignOutEvent>(_onSignOut);
    on<ResetPasswordEvent>(_onResetPasswordEvent);
    on<ShowLoginPageEvent>(_onShowLoginPage);
    on<ShowRegisterPageEvent>(_onShowRegisterPage);
    on<ShowResetPasswordPageEvent>(_onShowResetPasswordPage);
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await signInWithEmail(
      SignInWithEmailParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emitIfUserNotNull(user, emit),
    );
  }

  Future<void> _onRegisterWithEmail(
    RegisterWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerWithEmail(
      RegisterWithEmailParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emitIfUserNotNull(user, emit),
    );
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInWithGoogle(NoParams());

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emitIfUserNotNull(user, emit),
    );
  }

  Future<void> _onSignInWithApple(
    SignInWithAppleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInWithApple(NoParams());

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emitIfUserNotNull(user, emit),
    );
  }

  Future<void> _onGetCurrentUser(
    GetCurrentUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await getCurrentUser(NoParams());

    result.fold((failure) => emit(AuthInitial()), (user) {
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthInitial());
      }
    });
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signOut(NoParams());

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthInitial()),
    );
  }

  void emitIfUserNotNull(UserEntity? user, Emitter<AuthState> emit) {
    if (user != null) {
      emit(AuthSuccess(user));
    } else {
      emit(const AuthFailure('Register or login to continue'));
    }
  }

  FutureOr<void> _onShowLoginPage(
    ShowLoginPageEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthShowLogin());
  }

  FutureOr<void> _onShowRegisterPage(
    ShowRegisterPageEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthShowRegister());
  }

  FutureOr<void> _onShowResetPasswordPage(
    ShowResetPasswordPageEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthShowPasswordReset());
  }

  FutureOr<void> _onResetPasswordEvent(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(ResetPasswordLoading());

    final result = await resetPassword(ResetPasswordParams(email: event.email));
    result.fold(
      (failure) => emit(ResetPasswordFailure(message: failure.message)),
      (_) => emit(ResetPasswordSuccess(email: event.email)),
    );
  }
}
