import 'package:admin/models/user.dart';
import 'package:admin/network/api_service.dart';
import 'package:admin/network/token.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthEvent {}

class SignupEvent extends AuthEvent {
  final String username, email, firstName, lastName, password, password2;
  SignupEvent({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.password2,
  });
}

class LoginEvent extends AuthEvent {
  final String username, password;
  LoginEvent({required this.username, required this.password});
}

class LogoutEvent extends AuthEvent {}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}

class RegSuccess extends AuthState {
  final AuthResponse response;
  RegSuccess(this.response);
}

class AuthFailure extends AuthState {
  final Exception error;
  AuthFailure(this.error);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;
  final TokenManager tokenManager;


  AuthBloc(this.apiService, this.tokenManager)
      : super(tokenManager.user != null
            ? AuthSuccess(tokenManager.user!)
            : AuthInitial()) {

    on<SignupEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await apiService.signup(
          event.username,
          event.email,
          event.firstName,
          event.lastName,
          event.password,
          event.password2,
        );
        emit(RegSuccess(response));
      } catch (e) {
        emit(AuthFailure(Exception('User data not received')));
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await apiService.login(event.username, event.password);
        await tokenManager.saveAuthResponse(response);
        if (response.user != null) {
          emit(AuthSuccess(response.user!));
        } else {
          emit(AuthFailure(Exception('User data not received')));
        }
      } catch (e) {
        emit(AuthFailure(e is Exception ? e : Exception(e.toString())));
      }
    });

    on<LogoutEvent>((event, emit) async {
      await tokenManager.clearAll();
      emit(AuthInitial());
    });
  }
}
