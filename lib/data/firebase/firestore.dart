// Reference: https://firebase.flutter.dev/docs/firestore/usage/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:makani/data/models/makan.dart';
import 'package:makani/data/models/user.dart';

class Firestore {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final CollectionReference _makansCollection =
      FirebaseFirestore.instance.collection("makans");
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection("users");

  //////////// Makan ////////////

  Future<String> addMakan(Map<String, dynamic> values) async {
    String? uid = _auth.currentUser?.uid;
    String newDocId = _makansCollection.doc().id;
    if (uid != null)
      await _makansCollection.doc(newDocId).set({
        'id': newDocId,
        'owner': uid,
        'title': values['title'],
        'details': values['details'],
        'category': values['category'] ?? 1,
        'hobby': values['hobby'] ?? 0,
        'business': values['business'] ?? 0,
        'latlng':
            GeoPoint(values['latlng'].latitude, values['latlng'].longitude),
        'from': values['from'],
        'to': values['to'],
        'created': DateTime.now(),
        'updated': DateTime.now(),
      }).catchError((error) => print("addMakan error: $error"));
    else
      print("addMakan error: newDocId or uid is null!");
    return newDocId;
  }

  Future<void> updateMakan(Map<String, dynamic> values) {
    return _makansCollection.doc(values['id']).set({
      'title': values['title'],
      'details': values['details'],
      'category': values['category'] ?? 1,
      'hobby': values['hobby'] ?? 0,
      'business': values['business'] ?? 0,
      'from': values['from'],
      'to': values['to'],
      'updated': DateTime.now(),
    }, SetOptions(merge: true)).catchError(
        (error) => print("updateMakan error: $error"));
  }

  Future<void> deleteMakan(String id) async {
    //todo-ask: can we one query like: delete id where owner is uid ?
    String? uid = _auth.currentUser?.uid;
    QuerySnapshot query = await _makansCollection
        .where('id', isEqualTo: id)
        .where('owner', isEqualTo: uid)
        .get();
    return query.size != 1
        ? null
        : await _makansCollection
            .doc(id)
            .delete()
            .catchError((error) => print("deleteMakan error: $error"));
  }

  //todo: all makans! What if we have too many?
  //Abdullah: yes. We have to use some sort of algorithm or some google api
  //like geo-fence, etc. Research needed.
  Future<List<Makan>> getAllMakans(MUser? user, List<bool> filters) async {
    if (!filters[0] && !filters[1] && !filters[2]) {
      return [];
    } else {
      List<Makan> listMakans = [];
      List friendsMakans = [];
      // getting followers makans
      if (filters[0] && user != null) {
        friendsMakans.addAll(user.followers);
        friendsMakans.add(user.id); //show my makans also
        QuerySnapshot query = await _makansCollection
            .where('owner',
                whereIn:
                    friendsMakans) //todo: won't work if array is greater than 10
            .where('category', isEqualTo: 1)
            .get();
        listMakans = query.docs
            .map((m) => Makan.fromSnapshot(m.data() as Map<String, dynamic>))
            .toList();
      }
      // getting public and business makans
      if (filters[1] || filters[2]) {
        List filter = [];
        if (filters[1]) filter.add(2);
        if (filters[2]) filter.add(3);
        QuerySnapshot query =
            await _makansCollection.where('category', whereIn: filter).get();
        listMakans.addAll(query.docs
            .map((m) => Makan.fromSnapshot(m.data() as Map<String, dynamic>))
            .toList());
      }
      return listMakans;
    }
  }

  Future<List<Makan>> getMyMakans() async {
    String? uid = _auth.currentUser?.uid;
    QuerySnapshot querySnapshot =
        await _makansCollection.where('owner', isEqualTo: uid).get();
    return querySnapshot.docs
        .map((m) => Makan.fromSnapshot(m.data() as Map<String, dynamic>))
        .toList();
  }

  // not used now
  // Future<Makan> makanDetails(String id) async {
  //   QuerySnapshot querySnapshot =
  //       await _makansCollection.where('id', isEqualTo: id).get();
  //   return Makan.fromSnapshot(querySnapshot.docs.single.data());
  // }

  //////////// User ////////////
  Future<void> addNewUser(String mobile) async {
    String? uid = _auth.currentUser?.uid;
    try {
      DocumentSnapshot documentSnapshot = await _userCollection.doc(uid).get();
      if (!documentSnapshot.exists) {
        await _userCollection.doc(uid).set({
          "id": uid,
          "name": "",
          "mobile": mobile,
          "image": "",
          "notification": 1,
          'created': DateTime.now(),
          'updated': DateTime.now(),
        }).catchError((error) => print("addNewUser error: $error"));
      }
    } catch (error) {
      print('addNewUser error: $error');
    }
  }

  Future<List<MUser>> getAllUsers() async {
    QuerySnapshot querySnapshot = await _userCollection.get();
    return querySnapshot.docs
        .map((user) => MUser.fromSnapshot(user.data() as Map<String, dynamic>))
        .toList();
  }

  Future<MUser> getUserDataOnce() async {
    String? uid = _auth.currentUser?.uid;
    DocumentSnapshot documentSnapshot = await _userCollection.doc(uid).get();
    return MUser.fromSnapshot(documentSnapshot.data() as Map<String, dynamic>);
  }

  Stream<MUser?> getUserData() {
    String? uid = _auth.currentUser?.uid;
    return _userCollection.doc(uid).snapshots().map((snapshot) {
      return (snapshot.data() != null)
          ? MUser.fromSnapshot(snapshot.data() as Map<String, dynamic>)
          : null;
    });
  }

  Future<void> updateUserName(String name) async {
    String? uid = _auth.currentUser?.uid;
    await _userCollection
        .doc(uid)
        .update({"name": name, 'updated': DateTime.now()}).catchError(
            (error) => print("updateUserName error: $error"));
  }

  Future<void> updateUserImage(String fileURL) async {
    String? uid = _auth.currentUser?.uid;
    await _userCollection
        .doc(uid)
        .update({"image": fileURL, 'updated': DateTime.now()}).catchError(
            (error) => print("updateUserImage error: $error"));
  }

  Future<void> updateNotification(int ns) async {
    String? uid = _auth.currentUser?.uid;
    await _userCollection
        .doc(uid)
        .update({"notification": ns, 'updated': DateTime.now()}).catchError(
            (error) => print("updateNotification error: $error"));
  }

  Future<void> updateDeviceToken([String? token]) async {
    String? uid = _auth.currentUser?.uid;
    token = token ?? await _messaging.getToken();
    await _userCollection.doc(uid).update({'token': token}).catchError(
        (error) => print("updateDeviceToken error: $error"));
  }

  Future<bool> isUser(String mobile) async {
    QuerySnapshot querySnapshot =
        await _userCollection.where('mobile', isEqualTo: mobile).get();
    return querySnapshot.docs.length > 0 ? true : false;
  }

  //////////// Friends ////////////
  Stream<List<Stream<MUser>>> getAllMyFriends() {
    String? uid = _auth.currentUser?.uid;
    //todo-ask: use _userCollection instead of _firestore.collection('users')
    return _firestore.collection('users').doc(uid).snapshots().map((user) {
      List list = user.data()!['friends'];
      return list.map((friendId) {
        return _userCollection.doc(friendId).snapshots().map((event) =>
            MUser.fromSnapshot(event.data() as Map<String, dynamic>));
      }).toList();
    });
  }

  Future<List<String?>> getAllMyFriendsTokens() async {
    String? uid = _auth.currentUser?.uid;
    List<String?> listFriendsTokens = [];
    DocumentSnapshot userDocumentSnapshot =
        await _userCollection.doc(uid).get();
    final data = userDocumentSnapshot.data() as Map<String, dynamic>;
    List friends = data['friends'];
    if (friends.length > 0) {
      QuerySnapshot friendsQuerySnapshot = await _firestore
          .collection('users')
          .where('id', whereIn: friends)
          .get(); //todo: only list of 10 objects allowed in firestore query

      for (var friendSnapshot in friendsQuerySnapshot.docs) {
        MUser friend =
            MUser.fromSnapshot(friendSnapshot.data() as Map<String, dynamic>);
        if (friend.notification != null &&
            (friend.notification == 1 || friend.notification == 2)) {
          if (friend.token != null) {
            listFriendsTokens.add(friend.token);
          }
        }
      }
      // for (var qs in friendsQuerySnapshot.docs) {
      //   String friendUid = qs.data()['uId'];
      //   DocumentSnapshot documentSnapshot =
      //       await _userCollection.doc(friendUid).get();
      //   MUser friend = MUser.fromSnapshot(documentSnapshot.data());
      //   print('friend - ${friend.mobile}');
      //   if (friend.notification != null &&
      //       (friend.notification == 1 || friend.notification == 2)) {
      //     if (friend.token != null) {
      //       listFriendsTokens.add(friend.token);
      //     }
      //   }
      // }
    }

    return listFriendsTokens;
  }

  Future<void> addFriend(String mobile) async {
    List? friendsList = [];
    String? uid = _auth.currentUser?.uid;
    QuerySnapshot querySnapshot =
        await _userCollection.where('mobile', isEqualTo: mobile).get();
    String friendId = querySnapshot.docs.first.id;
    DocumentReference documentReference = _userCollection.doc(uid);
    DocumentSnapshot user = await documentReference.get();
    final data = user.data() as Map<String, dynamic>;
    if (await data['friends'] == null) {
      friendsList.add(friendId);
    } else {
      friendsList = await data['friends'];
      if (!friendsList!.contains(friendId)) friendsList.add(friendId);
    }
    documentReference.update({'friends': friendsList}).catchError(
        (error) => print("addFriend error: $error"));
    addAFollower(uid, friendId);
  }

  Future<void> addAFollower(String? uid, String friendId) async {
    List? followersList = [];
    DocumentReference documentReference = _userCollection.doc(friendId);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    if (documentSnapshot.exists) {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      if (data['followers'] == null) {
        followersList.add(uid);
      } else {
        followersList = data['followers'];
        if (!followersList!.contains(uid)) followersList.add(uid);
      }
      documentReference.update({'followers': followersList}).catchError(
          (error) => print("addAFollower error: $error"));
    }
  }

  Future<void> deleteFriend(String mobile) async {
    String? uid = _auth.currentUser?.uid;
    QuerySnapshot querySnapshot =
        await _userCollection.where('mobile', isEqualTo: mobile).get();
    String friendId = querySnapshot.docs.first.id;

    DocumentSnapshot user = await _userCollection.doc(uid).get();
    final data = user.data() as Map<String, dynamic>;
    if (await data['friends'] != null) {
      List friendsList = data['friends'];
      if (friendsList.contains(friendId)) {
        friendsList.remove(friendId);
        _userCollection.doc(uid).update({'friends': friendsList}).catchError(
            (error) => print("deleteFriend error: $error"));
      }
    }
    removeAFollower(uid!, friendId);
  }

  Future<void> removeAFollower(String uid, String friendId) async {
    List? followersList = [];
    DocumentReference documentReference = _userCollection.doc(friendId);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    if (documentSnapshot.exists) {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      if (data['followers'] != null) {
        followersList = data['followers'];
        if (followersList!.contains(uid)) {
          followersList.remove(uid);
          documentReference.update({'followers': followersList}).catchError(
              (error) => print("removeAFollower error: $error"));
        }
      }
    }
  }

  Future<bool> isFriend(String mobile) async {
    List? friendsList = [];
    String? uid = _auth.currentUser?.uid;
    QuerySnapshot querySnapshot =
        await _userCollection.where('mobile', isEqualTo: mobile).get();

    String friendId = querySnapshot.docs.first.id;
    DocumentSnapshot user = await _userCollection.doc(uid).get();
    final data = user.data() as Map<String, dynamic>;
    if (await data['friends'] == null) {
      return false;
    } else {
      friendsList = await data['friends'];
      if (friendsList!.contains(friendId)) {
        return true;
      } else {
        return false;
      }
    }
  }
}
