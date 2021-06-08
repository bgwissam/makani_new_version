import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makani/data/firebase/firestore.dart';
import 'package:makani/data/models/user.dart';

//todo: when start after stop, user is logged out, if restart, user is login!

class MUserCubit extends Cubit<MUser?> {
  Firestore firestore = Firestore();
  FirebaseAuth auth = FirebaseAuth.instance;

  MUserCubit() : super(null);

  void user() {
    try {
      auth.authStateChanges().listen((User? firebaseUser) {
        if (firebaseUser != null) {
          print(
              'MUserCubit.user firebaseUser is NOT null: ${firebaseUser.uid}');
          Stream<MUser?> stream = firestore.getUserData();
          stream.listen((MUser? user) {
            //todo-ask: after logout, this stream still working and firebaseUser.uid still not null
            // until restart. That's why I use this if
            print('MUserCubit.user Stream<MUser?> is called');
            print('MUserCubit.user stream 0: $user ${user?.name}');
            if (auth.currentUser != null) {
              print('MUserCubit.user currentUser: ${auth.currentUser}');
              print('MUserCubit.user firebaseUser: ${firebaseUser.uid}');
              print('MUserCubit.user stream: $user ${user?.name}');
              emit(user);
            }
          });
        } else {
          print('MUserCubit.user firebaseUser is null');
          emit(null);
        }
      });
    } catch (error) {
      print('MUserCubit.user: $error');
    }
  }

  Future<void> signOut() async {
    try {
      await firestore.updateDeviceToken(''); // delete token
      await auth.signOut();
      emit(null);
    } catch (error) {
      print('MUserCubit.signOut: $error');
    }
  }
}
