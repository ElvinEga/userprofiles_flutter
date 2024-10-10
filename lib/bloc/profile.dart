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

class UpdateProfileEvent extends ProfileEvent {
  final int userId;
  final Map<String, dynamic> updatedData;

  UpdateProfileEvent({required this.userId, required this.updatedData});
}

class CreateProfileEvent extends ProfileEvent {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String password;

  CreateProfileEvent({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
  });
}

class DeleteProfileEvent extends ProfileEvent {
  final int userId;
  DeleteProfileEvent(this.userId);
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

    on<CreateProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final newProfile = await apiService.createProfile(
          event.username,
          event.email,
          event.firstName,
          event.lastName,
          event.password,
        );
        final profiles = await apiService.getProfiles();
        emit(ProfileLoaded(profiles)); // Refresh the profile list after creation
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    on<UpdateProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        await apiService.updateProfile(event.userId, event.updatedData);
        final profiles = await apiService.getProfiles();
        emit(ProfileLoaded(profiles)); // Refresh the profile list after update
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    on<DeleteProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        await apiService.deleteProfile(event.userId);
        final profiles = await apiService.getProfiles();
        emit(ProfileLoaded(profiles)); // Refresh the profile list after deletion
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

  }
}