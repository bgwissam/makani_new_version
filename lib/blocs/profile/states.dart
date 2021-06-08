part of 'bloc.dart';

@immutable
abstract class ProfileStates {}

class InitialProfileState extends ProfileStates {}

class DataProfileState extends ProfileStates {
  final Profiles profiles;
  final MUser? user;
  final String? message;

  DataProfileState({required this.profiles, this.user, this.message});
}

class ErrorProfileState extends ProfileStates {
  final String message;

  ErrorProfileState({required this.message});
}
