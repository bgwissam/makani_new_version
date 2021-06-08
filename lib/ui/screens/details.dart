import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makani/blocs/cubits/user.dart';
import 'package:makani/blocs/cubits/friends.dart';
import 'package:makani/blocs/cubits/map.dart';
import 'package:makani/data/models/categories.dart';
import 'package:makani/data/models/makan.dart';
import 'package:makani/data/models/user.dart';
import 'package:makani/ui/utils/theme.dart';
import 'package:makani/ui/utils/utils.dart';
import 'package:makani/ui/widgets/photo.dart';
import 'package:map_launcher/map_launcher.dart';

class Details {
  final BuildContext context;
  final Makan makan;
  final MUser owner;

  Details(this.context, this.makan, this.owner);

  void sheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.85,
          minChildSize: 0.0,
          //close it when click outside
          expand: false,
          builder: (_, ScrollController controller) => _contents(controller),
        );
      },
    );
  }

  Widget _contents(ScrollController controller) {
    final MUser? user = context.watch<MUserCubit>().state;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Column(
          children: [
            MTheme.sheetBar(),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                child: Column(children: [
                  Container(
                    height: MediaQuery.of(context).size.width,
                    width: MediaQuery.of(context).size.width - 36,
                    child: Stack(
                      children: [
                        photo(MediaQuery.of(context).size.width - 36,
                            url: owner.image, radius: 'all'),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 32),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.75),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    owner.name ?? owner.mobile.substring(1),
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.headline1,
                                  ),
                                  if (owner.name != null)
                                    Text(
                                      owner.mobile.substring(1),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            _makanControls(user),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(top: 5),
                    padding: EdgeInsets.all(8),
                    child: Column(children: [
                      Text(
                        makan.title,
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      (makan.hobby != 0)
                          ? Text(
                              tr('hobby') + ': ' + tr(hobbies[makan.hobby]!),
                              style: Theme.of(context).textTheme.headline2,
                              textAlign: TextAlign.center,
                            )
                          : (makan.business != 0)
                              ? Text(
                                  tr('business') +
                                      ': ' +
                                      tr(businesses[makan.business]!),
                                  style: Theme.of(context).textTheme.headline1,
                                  textAlign: TextAlign.center,
                                )
                              : SizedBox(),
                      SizedBox(
                          height: (makan.hobby != 0 || makan.business != 0)
                              ? 8
                              : 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(tr("from")),
                          Text(Utils.formatDate(makan.from)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(tr("to")),
                          Text(Utils.formatDate(makan.to)),
                        ],
                      ),
                      Text(
                        "(" + Utils.getDateStatus(makan.from, makan.to) + ")",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                    ]),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(16),
                    child: Text(makan.details, textAlign: TextAlign.justify),
                  ),
                  Divider(thickness: 1, height: 16, indent: 16, endIndent: 16),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(top: 16, bottom: 32),
                    child: (user?.id == makan.owner)
                        ? _ownerControls()
                        : Container(),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _makanControls(MUser? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (user != null && user.id != makan.owner)
          Container(
            width: 64,
            height: 64,
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),
            child: BlocListener<FriendsCubit, FriendsState>(
              listener: (context, state) {
                if (state.status == FriendsStatus.Added)
                  ScaffoldMessenger.of(context)
                      .showSnackBar(Utils.snackBar(tr('friendAdded')));
                else if (state.status == FriendsStatus.AlreadyFriend)
                  ScaffoldMessenger.of(context)
                      .showSnackBar(Utils.snackBar(tr('friendAlready'), false));
              },
              child: InkWell(
                  splashColor: Colors.white,
                  highlightColor: Colors.white, //for long tap
                  onTap: () => context.read<FriendsCubit>().friends(
                      userMobile: user.mobile, addMobile: owner.mobile),
                  child: Column(children: [
                    Icon(Icons.person_add,
                        color: Theme.of(context).primaryColor),
                    Text(tr('friend'),
                        style: Theme.of(context).textTheme.headline4)
                  ])),
            ),
          ),
        Container(
          width: 64,
          height: 64,
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          child: InkWell(
              splashColor: Colors.white,
              highlightColor: Colors.white, //for long tap
              onTap: () async {
                await MapLauncher.showMarker(
                  mapType: (await MapLauncher.isMapAvailable(MapType.google))!
                      ? MapType.google
                      : MapType.apple,
                  coords: Coords(makan.latitude, makan.longitude),
                  title: makan.title,
                );
              },
              child: Column(children: [
                Icon(Icons.directions, color: Theme.of(context).primaryColor),
                Text(tr('map'), style: Theme.of(context).textTheme.headline4)
              ])),
        ),
        Container(
          width: 64,
          height: 64,
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          child: InkWell(
              splashColor: Colors.white,
              highlightColor: Colors.white, //for long tap
              onTap: () => Utils.callMobile(owner.mobile),
              child: Column(children: [
                Icon(Icons.call, color: Theme.of(context).primaryColor),
                Text(tr('call'), style: Theme.of(context).textTheme.headline4)
              ])),
        ),
        Container(
          width: 64,
          height: 64,
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          child: InkWell(
            splashColor: Colors.white,
            highlightColor: Colors.white, //for long tap
            onTap: () async => Utils.sendWhatsapp(owner.mobile),
            child: Column(children: [
              Icon(Icons.chat, color: Theme.of(context).primaryColor),
              Text(tr('whatsapp'), style: Theme.of(context).textTheme.headline4)
            ]),
          ),
        ),
      ],
    );
  }

  Widget _ownerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          onTap: () async {
            if (makan.to.isAfter(DateTime.now()))
              await Navigator.pushNamed(context, '/update');
            else
              ScaffoldMessenger.of(context)
                  .showSnackBar(Utils.snackBar(tr('makanCantUpdated')));
          },
          child: Icon(
            Icons.edit,
            color: makan.to.isAfter(DateTime.now())
                ? Theme.of(context).primaryColor
                : MTheme.unSelectedColor,
          ),
        ),
        InkWell(
          onTap: () => _alertDelete(),
          child: Icon(Icons.delete, color: Theme.of(context).primaryColor),
        ),
      ],
    );
  }

  void _alertDelete() {
    Widget _button1() {
      return TextButton(
        child: Text(tr("yes")),
        onPressed: () async {
          Navigator.pop(context); // for dialog
          Navigator.pop(context); // for details sheet
          await context.read<MapCubit>().update(
              debug: 'details: MapAction.Delete',
              action: MapAction.Delete,
              makanId: makan.id);
        },
      );
    }

    Widget _button2() {
      return TextButton(
        child: Text(tr("no")),
        onPressed: () => Navigator.pop(context),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return (Platform.isIOS)
            ? CupertinoAlertDialog(
                title: Text(tr("alertDeleteMakan")),
                actions: <Widget>[_button1(), _button2()],
              )
            : AlertDialog(
                title: Text(tr("alertDeleteMakan")),
                actions: <Widget>[_button1(), _button2()],
              );
      },
    );
  }
}
