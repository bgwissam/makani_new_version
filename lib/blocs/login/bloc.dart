import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makani/data/firebase/firestore.dart';

part 'events.dart';

part 'states.dart';

class LoginBloc extends Bloc<LoginEvents, LoginStates> {
  FirebaseAuth auth = FirebaseAuth.instance;
  Firestore firestore = Firestore();
  String verificationId = "";
  int failedAttempts = 0;

  LoginBloc() : super(InitialLoginState());

  @override
  Stream<LoginStates> mapEventToState(LoginEvents event) async* {
    if (event is InitialLoginEvent) {
      failedAttempts = 0;
      yield InitialLoginState(); //to reset other states
    } else if (event is LoggingOutEvent) {
      yield SuccessLogoutState();
    } else if (event is LoggingInEvent) {
      yield LoadingLoginState();
      sendOtp(event.mobile).listen((event) => add(event));
    } else if (event is OtpSentEvent) {
      yield OtpSentState();
    } else if (event is ErrorLoginEvent) {
      yield ErrorLoginState(message: event.message);
    } else if (event is OtpVerifyEvent) {
      yield LoadingLoginState();
      try {
        PhoneAuthCredential credential = (event.authCredential != null)
            ? event.authCredential! // android only
            : PhoneAuthProvider.credential(
                verificationId: verificationId, smsCode: event.smsCode!);
        UserCredential userCredential =
            await auth.signInWithCredential(credential);
        if (userCredential.user != null) {
          await firestore.addNewUser(userCredential.user!.phoneNumber!);
          await firestore.updateDeviceToken();
          yield SuccessLoginState(user: userCredential.user!);
        }
      } catch (error) {
        print('login.bloc OtpVerifyEvent error: $error');
        if (failedAttempts++ > 3) failedAttempts = 0;
        yield OtpExceptionState(failedAttempts);
      }
    }
  }

  Stream<LoginEvents> sendOtp(String mobile) async* {
    StreamController<LoginEvents> streamController = StreamController();
    await auth.verifyPhoneNumber(
      phoneNumber: mobile,
      verificationCompleted: (PhoneAuthCredential authCredential) {
        // for android only: auto read sms code //todo: it was working, but not working now!
        if (auth.currentUser != null) {
          streamController.add(OtpVerifyEvent(authCredential: authCredential));
          streamController.close();
        }
      },
      verificationFailed: (FirebaseAuthException error) {
        print(
            'login.bloc verificationFailed, code: ${error.code} - message: ${error.message}');
        streamController.add(ErrorLoginEvent('authException'));
        streamController.close();
      },
      codeSent: (String verificationId, int? resendToken) {
        this.verificationId = verificationId;
        streamController.add(OtpSentEvent());
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // for android only: if auto read sms code failed, then do like ios
        this.verificationId = verificationId;
        streamController.add(OtpSentEvent());
      },
    );
    yield* streamController.stream;
  }
}
