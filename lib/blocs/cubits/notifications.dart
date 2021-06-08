// https://firebase.flutter.dev/docs/messaging/overview/

//todo: no sound in IOs
//todo: what to do with notifications' alert in other than map's screen

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:makani/data/firebase/firestore.dart';

class Message {
  final bool isIOSGranted; //todo: not tested
  final String? id;
  final String? title;
  final String? body;
  final LatLng? latlng;
  final String? error;

  Message(
      {this.isIOSGranted = false,
      this.id,
      this.title,
      this.body,
      this.latlng,
      this.error});
}

class NotificationsCubit extends Cubit<Message> {
  final Firestore firestore = Firestore();
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  bool _isIOSGranted = false;

  NotificationsCubit() : super(Message()) {
    _notifications();
  }

  Future<void> _iOSPermission() async {
    // ios only. Android is authorized by default.
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: true,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    //todo: do we need to alert when no permission?
    _isIOSGranted =
        settings.authorizationStatus == AuthorizationStatus.authorized;
    reset(); //to emit _isIOSGranted
    print(
        'Notifications: User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _saveToken() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await firestore.updateDeviceToken();
      // Any time the token refreshes, save it. //todo: not tested!
      messaging.onTokenRefresh
          .listen((token) async => await firestore.updateDeviceToken(token));
    }
  }

  void _notifications() async {
    if (Platform.isIOS) await _iOSPermission();
    await _saveToken();

    // terminated
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage?.data['id'] != null) _emit(initialMessage!);

    // background
    FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage message) => _emit(message));

    // foreground
    FirebaseMessaging.onMessage
        .listen((RemoteMessage message) => _emit(message));
  }

  void _emit(RemoteMessage message) {
    emit(Message(
      isIOSGranted: _isIOSGranted,
      id: message.data["id"],
      title: message.data["title"],
      body: message.data["body"],
      latlng: LatLng(
        double.parse(message.data["latitude"]),
        double.parse(message.data["longitude"]),
      ),
    ));
  }

  void reset() {
    emit(Message(isIOSGranted: _isIOSGranted));
  }
}
