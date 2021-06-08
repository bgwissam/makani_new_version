part of 'bloc.dart';

@immutable
abstract class LoginEvents {}

class InitialLoginEvent extends LoginEvents {}

class LoggingOutEvent extends LoginEvents {}

class LoggingInEvent extends LoginEvents {
  final String mobile;

  LoggingInEvent({required this.mobile});
}

class OtpSentEvent extends LoginEvents {}

class OtpVerifyEvent extends LoginEvents {
  final String? smsCode;
  final PhoneAuthCredential? authCredential;

  OtpVerifyEvent({this.smsCode, this.authCredential});
}

class ErrorLoginEvent extends LoginEvents {
  final String message;

  ErrorLoginEvent(this.message);
}
