import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:makani/data/firebase/firestore.dart';
import 'package:http/http.dart' as http;
import 'package:makani/data/models/user.dart';

class Messaging {
  newMakan(String id, LatLng latlng, MUser user) async {
    try {
      List<String?> listOfTokens = await Firestore().getAllMyFriendsTokens();
      print('Notifications: messaging listOfTokens: $listOfTokens');
      if (listOfTokens.length > 0) {
        var response = await http.post(
          //await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAASYXHqZM:APA91bHYqqgRw72EkuxIhpYwnn3oa6WjK6v1PP31seKYSOwidN2nWXmXuIdKILyFXqIUsWVBjpRKomBOAhUmd6Pn_B_CHU-rpbSJ9XlBoCDNg7z2UHskWaxRbu87VoQq9-oEfecIdPiN',
          },
          body: jsonEncode(<String, dynamic>{
            // 'priority': 'high',
            'registration_ids': listOfTokens,
            // 'notification': <String, dynamic>{
            //   'type': 'new_makan',
            //   'id': '$id',
            //   'title': 'New Makan Added',
            //   'body': 'Your friend ${user.name ?? user.mobile} added a new makan.',
            //   'latitude': '${latlng.latitude}',
            //   'longitude': '${latlng.longitude}',
            // },
            'data': <String, dynamic>{
              'type': 'new_makan',
              'id': '$id',
              'title': 'New Makan Added',
              'body':
                  'Your friend ${user.name ?? user.mobile} added a new makan.',
              'latitude': '${latlng.latitude}',
              'longitude': '${latlng.longitude}',
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          }),
        );
        print('Notifications: messaging response: ${response.statusCode}');
      }
    } catch (error) {
      print('Notifications: Messaging error: $error');
    }
  }
}
