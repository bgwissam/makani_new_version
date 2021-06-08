import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:makani/blocs/cubits/user.dart';
import 'package:makani/blocs/cubits/friends.dart';
import 'package:makani/data/models/user.dart';
import 'package:makani/ui/utils/theme.dart';
import 'package:makani/ui/utils/utils.dart';
import 'package:makani/ui/widgets/mobile.dart';
import 'package:makani/ui/widgets/photo.dart';

class Friends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MUser? user = context.watch<MUserCubit>().state;
    if (user == null) {
      return Container();
    } else {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('addFriend'),
                  style: Theme.of(context).textTheme.headline2),
              InkWell(
                onTap: () async {
                  try {
                    await FlutterContactPicker.requestPermission();
                    if (await FlutterContactPicker.hasPermission()) {
                      final PhoneContact contact =
                          await FlutterContactPicker.pickPhoneContact();
                      if (contact.phoneNumber != null) {
                        context.read<FriendsCubit>().friends(
                              userMobile: user.mobile,
                              addMobile: contact.phoneNumber!.number!,
                            );
                      }
                    } else {
                      alertMyContacts(context);
                    }
                  } catch (e) {
                    print('contacts permission error: $e');
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tr('myContacts'),
                      style: Theme.of(context).textTheme.headline2!.copyWith(
                          color: Theme.of(context).textTheme.subtitle2!.color,
                          decoration: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .decoration),
                    ),
                    Text(' '),
                    Icon(Icons.import_contacts,
                        color: Theme.of(context).primaryColor),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(tr('byMobile'),
                  style: Theme.of(context).textTheme.headline2),
              MobileField(),
              Divider(thickness: 1, height: 48),
              Text(tr('friends') + ':',
                  style: Theme.of(context).textTheme.headline2),
              SizedBox(height: 8),
              BlocConsumer<FriendsCubit, FriendsState>(
                builder: (context, state) {
                  return state.status == FriendsStatus.Loading
                      ? MTheme.loader()
                      : _friendsListView(state.friends);
                },
                listener: (context, state) {
                  if (state.status == FriendsStatus.Added)
                    ScaffoldMessenger.of(context)
                        .showSnackBar(Utils.snackBar(tr('friendAdded')));
                  else if (state.status == FriendsStatus.Deleted)
                    ScaffoldMessenger.of(context)
                        .showSnackBar(Utils.snackBar(tr('friendDeleted')));
                  else if (state.status == FriendsStatus.YourMobile)
                    ScaffoldMessenger.of(context).showSnackBar(
                        Utils.snackBar(tr('friendYourself'), false));
                  else if (state.status == FriendsStatus.AlreadyFriend)
                    ScaffoldMessenger.of(context).showSnackBar(
                        Utils.snackBar(tr('friendAlready'), false));
                  else if (state.status == FriendsStatus.NotUser)
                    ScaffoldMessenger.of(context).showSnackBar(Utils.snackBar(
                      tr('friendInvited'),
                      false,
                      state.mobile!.trim(),
                    ));
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _friendsListView(Stream<List<Stream<MUser>>>? friends) {
    return StreamBuilder<List<Stream<MUser>>>(
      stream: friends,
      builder: (context, listOfStreamOfUsers) {
        if (listOfStreamOfUsers.connectionState != ConnectionState.active)
          return MTheme.loader();
        if (listOfStreamOfUsers.hasData &&
            listOfStreamOfUsers.data!.length > 0) {
          //sometime there's data which is empty list [], so we need to check the length.
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: listOfStreamOfUsers.data!.length,
            itemBuilder: (context, index) {
              return StreamBuilder<MUser>(
                stream: listOfStreamOfUsers.data![index],
                builder: (context, streamOfUser) =>
                    (streamOfUser.connectionState != ConnectionState.active ||
                            !streamOfUser.hasData)
                        ? MTheme.loader()
                        : _friendCard(context, streamOfUser.data!),
              );
            },
          );
        } else {
          return Center(child: Icon(Icons.mood_bad, size: 32));
        }
      },
    );
  }

  Widget _friendCard(BuildContext context, MUser user) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        photo(
          MediaQuery.of(context).size.width * 0.2,
          url: user.image,
          radius: context.locale.toString() == 'ar_SA' ? 'right' : 'left',
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user.name != null) Text(user.name.toString()),
              Text(user.mobile.substring(1).toString()),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.delete, color: MTheme.warningColor),
          onPressed: () =>
              context.read<FriendsCubit>().friends(deleteMobile: user.mobile),
        ),
      ]),
    );
  }

  void alertMyContacts(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return (Platform.isIOS)
            ? CupertinoAlertDialog(
                title: Text(tr("alertMyContactsTitle")),
                content: Text(tr("alertMyContactsDesc")),
                actions: <Widget>[
                  TextButton(
                    child: Text(tr("ok")),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              )
            : AlertDialog(
                title: Text(tr("alertMyContactsTitle")),
                content: Text(tr("alertMyContactsDesc")),
                actions: <Widget>[
                  TextButton(
                    child: Text(tr("ok")),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              );
      },
    );
  }
}
