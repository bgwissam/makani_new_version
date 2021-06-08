import 'package:cloud_firestore/cloud_firestore.dart';

// 'User' is used by Firebase
class MUser {
  String id;
  final String? name;
  final String mobile;
  final String? image;
  final String? token;
  final int? notification;
  final List followers;
  final List friends;
  final Timestamp created;
  final Timestamp updated;

  MUser.fromSnapshot(Map<String, dynamic> snapshot)
      : id = snapshot['id'],
        //if name is empty, then make sure it's null, because we use that in our code
        name = snapshot['name'] == '' ? null : snapshot['name'],
        mobile = snapshot['mobile'],
        image = snapshot['image'],
        token = snapshot['token'],
        notification = snapshot['notification'],
        followers = snapshot['followers'] ?? [],
        friends = snapshot['friends'] ?? [],
        created = snapshot['created'],
        updated = snapshot['updated'];
}
