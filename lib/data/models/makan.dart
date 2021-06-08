import 'package:cloud_firestore/cloud_firestore.dart';

class Makan {
  final String id;
  final String owner;
  final int category;
  final int hobby;
  final int business;
  final String title;
  final String details;
  final GeoPoint latlng;
  final DateTime from;
  final DateTime to;
  final DateTime created;
  final DateTime updated;

  Makan.fromSnapshot(Map<String, dynamic> snapshot)
      : id = snapshot['id'],
        owner = snapshot['owner'],
        category = snapshot['category'],
        hobby = snapshot['hobby'],
        business = snapshot['business'],
        title = snapshot['title'],
        details = snapshot['details'],
        latlng = snapshot['latlng'],
        from = snapshot['from'].toDate(),
        to = snapshot['to'].toDate(),
        created = snapshot['created'].toDate(),
        updated = snapshot['updated'].toDate();

  double get latitude => latlng.latitude;

  double get longitude => latlng.longitude;
}
