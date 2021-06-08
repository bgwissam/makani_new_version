import 'package:bloc/bloc.dart';
import 'package:makani/data/firebase/firestore.dart';
import 'package:makani/data/models/user.dart';

enum FriendsStatus {
  Added,
  Deleted,
  YourMobile,
  AlreadyFriend,
  NotUser,
  Loading
}

class FriendsState {
  final Stream<List<Stream<MUser>>>? friends;
  final FriendsStatus? status;
  final String? mobile;

  FriendsState({this.friends, required this.status, this.mobile});
}

class FriendsCubit extends Cubit<FriendsState> {
  Firestore firestore = Firestore();

  FriendsCubit() : super(FriendsState(status: FriendsStatus.Loading));

  Future<Stream<List<Stream<MUser>>>?> friends(
      {String? userMobile, addMobile, deleteMobile}) async {
    emit(FriendsState(status: FriendsStatus.Loading));
    FriendsStatus? status;
    if (userMobile != null && addMobile != null) {
      if (userMobile == addMobile) {
        status = FriendsStatus.YourMobile;
      } else if (!await firestore.isUser(addMobile)) {
        status = FriendsStatus.NotUser;
      } else if (await firestore.isFriend(addMobile)) {
        status = FriendsStatus.AlreadyFriend;
      } else {
        await firestore.addFriend(addMobile);
        status = FriendsStatus.Added;
      }
    }
    if (deleteMobile != null) {
      await firestore.deleteFriend(deleteMobile);
      status = FriendsStatus.Deleted;
    }
    Stream<List<Stream<MUser>>> friends = firestore.getAllMyFriends();
    emit(FriendsState(friends: friends, status: status, mobile: addMobile));
  }
}
