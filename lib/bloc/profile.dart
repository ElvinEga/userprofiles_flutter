import 'package:admin/models/user.dart';
import 'package:admin/network/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ProfileEvent {}

class LoadProfilesEvent extends ProfileEvent {}

// States
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final List<User> profiles;
  ProfileLoaded(this.profiles);
}
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ApiService apiService;

  ProfileBloc(this.apiService) : super(ProfileInitial()) {
    on<LoadProfilesEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profiles = await apiService.getProfiles();
        emit(ProfileLoaded(profiles));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}