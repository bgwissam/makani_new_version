import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:makani/data/firebase/firestore.dart';

class Storage {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final Firestore firestore = Firestore();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //upload profile image
  Future<void> uploadProfileImage(File image) async {
    Reference storageReference =
        storage.ref().child('profilePictures/${firebaseAuth.currentUser!.uid}');
    UploadTask uploadTask = storageReference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

    await taskSnapshot.ref.getDownloadURL().then((fileURL) {
      firestore.updateUserImage(fileURL);
    });
  }
}
