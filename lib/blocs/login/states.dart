part of 'bloc.dart';

@immutable
abstract class LoginStates {}

class InitialLoginState extends LoginStates {}

class LoadingLoginState extends LoginStates {}

class SuccessLogoutState extends LoginStates {}

class SuccessLoginState extends LoginStates {
  final User user;

  SuccessLoginState({required this.user});
}

class OtpSentState extends LoginStates {}

class OtpExceptionState extends LoginStates {
  final int failedAttempts;

  OtpExceptionState(this.failedAttempts);
}

class ErrorLoginState extends LoginStates {
  final String message;

  ErrorLoginState({required this.message});
}
