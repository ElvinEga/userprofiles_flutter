import 'package:admin/models/user.dart';
import 'package:admin/network/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
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

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final AuthResponse response;
  AuthSuccess(this.response);
}
class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;

  AuthBloc(this.apiService) : super(AuthInitial()) {
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
        emit(AuthSuccess(response));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await apiService.login(event.username, event.password);
        emit(AuthSuccess(response));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}