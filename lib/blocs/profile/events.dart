part of 'bloc.dart';

@immutable
abstract class ProfileEvents {}

class MobileProfileEvent extends ProfileEvents {}

class ImageProfileEvent extends ProfileEvents {
  final File? image;

  ImageProfileEvent({this.image});
}

class NameProfileEvent extends ProfileEvents {
  final String name;

  NameProfileEvent({required this.name});
}

class NotificationProfileEvent extends ProfileEvents {
  final int notification;

  NotificationProfileEvent({required this.notification});
}

class DataProfileEvent extends ProfileEvents {
  final String? message;
  final Profiles profiles;

  DataProfileEvent({this.message, required this.profiles});
}
