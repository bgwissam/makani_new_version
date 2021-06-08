import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:makani/data/models/user.dart';
import 'package:makani/data/firebase/firestore.dart';
import 'package:makani/data/firebase/storage.dart';

part 'events.dart';

part 'states.dart';

class ProfileBloc extends Bloc<ProfileEvents, ProfileStates> {
  Firestore firestore = Firestore();
  Storage storage = Storage();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  ProfileBloc() : super(InitialProfileState());

  @override
  Stream<ProfileStates> mapEventToState(ProfileEvents event) async* {
    if (event is NotificationProfileEvent) {
      await firestore.updateNotification(event.notification);
      yield DataProfileState(
        profiles: Profiles.NotificationUpdated,
        message: tr("notificationUpdated"),
      );
    } else if (event is MobileProfileEvent) {
      yield DataProfileState(
        profiles: Profiles.MobileUpdate,
        message: tr("mobileCantUpdate"),
      );
    } else if (event is NameProfileEvent) {
      await firestore.updateUserName(event.name);
      yield DataProfileState(
        profiles: Profiles.NameUpdated,
        message: tr("nameUpdated"),
      );
    } else if (event is ImageProfileEvent) {
      yield DataProfileState(profiles: Profiles.Loading, message: null);
      if (event.image != null) {
        await storage.uploadProfileImage(event.image!);
      } else {
        firestore.updateUserImage("");
      }
      yield DataProfileState(
        profiles: Profiles.ImageUpdated,
        message: event.image != null ? tr("imageUpdated") : tr("imageDeleted"),
      );
    }
  }
}

enum Profiles {
  DataUpdate,
  MobileUpdate,
  ImageUpdated,
  NotificationUpdated,
  NameUpdated,
  Loading,
}
