import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:makani/blocs/cubits/notifications.dart';
import 'package:makani/blocs/cubits/user.dart';
import 'package:makani/blocs/login/bloc.dart';
import 'package:makani/blocs/profile/bloc.dart';
import 'package:makani/data/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makani/ui/utils/theme.dart';
import 'package:makani/ui/utils/utils.dart';
import 'package:makani/ui/widgets/photo.dart';

class Profile extends StatefulWidget {
  final TabController? tabController;

  Profile(this.tabController);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _newImage;
  bool _deleteImage = false;
  bool _uploadingPhoto = false;
  bool _isIOSGranted = false;

  @override
  Widget build(BuildContext context) {
    final MUser? user = context.watch<MUserCubit>().state;
    if (user == null) return Container();

    if (Platform.isIOS) {
      _isIOSGranted = context
          .select((NotificationsCubit cubit) => cubit.state.isIOSGranted);
      print('isIOSGranted $_isIOSGranted');
      if (user.notification != 3 && !_isIOSGranted)
        context
            .read<ProfileBloc>()
            .add(NotificationProfileEvent(notification: 3));
    }

    return BlocListener<ProfileBloc, ProfileStates>(
      listener: (context, profileState) {
        if (profileState is DataProfileState) {
          if (profileState.message != null)
            ScaffoldMessenger.of(context).showSnackBar(Utils.snackBar(
              profileState.message!,
              profileState.profiles == Profiles.MobileUpdate ? false : true,
            ));
          if (profileState.profiles == Profiles.Loading)
            setState(() => _uploadingPhoto = true);
          else if (_uploadingPhoto) setState(() => _uploadingPhoto = false);
        }
      },
      child: _uploadingPhoto ? MTheme.loader() : _body(user),
    );
  }

  Widget _body(MUser user) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            Container(height: 32),
            Container(
              height: MediaQuery.of(context).size.width - 32 + 20,
              width: MediaQuery.of(context).size.width - 32,
              child: Stack(
                children: [
                  photo(
                    MediaQuery.of(context).size.width - 32,
                    path: _deleteImage ? null : _newImage,
                    url: _deleteImage ? null : user.image,
                    radius: 'all',
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => _addImage(),
                          child: Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Icon(
                              Icons.file_upload,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                        _deleteImage || (user.image == "" && _newImage == null)
                            ? SizedBox()
                            : SizedBox(width: 8.0),
                        _deleteImage || (user.image == "" && _newImage == null)
                            ? Container()
                            : InkWell(
                                onTap: () => _removeImage(),
                                child: Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: Icon(
                                    Icons.delete,
                                    color: Theme.of(context).primaryColor,
                                    size: 24,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  Container(height: 16),
                ],
              ),
            ),
            Container(height: 16),
            TextFormField(
              key: Key('mobile' + user.mobile.substring(1)),
              initialValue: user.mobile.substring(1),
              readOnly: true,
              onTap: () =>
                  context.read<ProfileBloc>().add(MobileProfileEvent()),
              decoration: InputDecoration(
                labelText: tr("mobile"),
                fillColor: Colors.black.withOpacity(0.1),
                filled: true,
              ),
            ),
            Container(height: 16),
            TextFormField(
              // without this key, initial value WONT change when rebuild
              key: Key('name' +
                  user.mobile
                      .substring(1)), //name may be null, don't use it here
              initialValue: user.name,
              decoration: InputDecoration(labelText: tr("name")),
              maxLength: 50,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) =>
                  value!.trim().length < 3 ? tr("nameError") : null,
              onFieldSubmitted: (value) {
                if (value.trim().length >= 3)
                  context
                      .read<ProfileBloc>()
                      .add(NameProfileEvent(name: value.trim()));
              },
            ),
            Container(height: 16),
            Column(children: <Widget>[
              Row(children: [
                Text(tr("notifications"),
                    style: TextStyle(color: MTheme.formLabel)),
              ]),
              RadioListTile(
                value: 1,
                groupValue: user.notification,
                contentPadding: EdgeInsets.symmetric(horizontal: 4),
                onChanged: (_) {
                  if (user.notification != 1) {
                    if (Platform.isAndroid || _isIOSGranted)
                      context
                          .read<ProfileBloc>()
                          .add(NotificationProfileEvent(notification: 1));
                    else
                      alertIOSNotGranted(context);
                  }
                },
                title: Text(tr("notificationsFromAllFriends")),
                // horizontalTitleGap: 2,
              ),
              RadioListTile(
                value: 2,
                groupValue: user.notification,
                contentPadding: EdgeInsets.symmetric(horizontal: 4),
                onChanged: (_) {
                  if (user.notification != 2) {
                    if (Platform.isAndroid || _isIOSGranted)
                      context
                          .read<ProfileBloc>()
                          .add(NotificationProfileEvent(notification: 2));
                    else
                      alertIOSNotGranted(context);
                  }
                },
                title: ExcludeSemantics(
                  //temp to solve a bug in recognizer
                  excluding: true,
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyText2,
                      children: [
                        TextSpan(text: tr("notificationsFrom")),
                        TextSpan(
                          text: tr("forMyFriends"),
                          style: Theme.of(context).textTheme.subtitle2,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => widget.tabController!.animateTo(1),
                        ),
                        TextSpan(text: tr("only.")),
                      ],
                    ),
                  ),
                ),
              ),
              RadioListTile(
                value: 3,
                groupValue: user.notification,
                contentPadding: EdgeInsets.symmetric(horizontal: 4),
                onChanged: (_) {
                  if (user.notification != 3)
                    context
                        .read<ProfileBloc>()
                        .add(NotificationProfileEvent(notification: 3));
                },
                title: Text(tr("notificationsNon")),
              ),
            ]),
            Container(height: 48),
            Container(
              width: 160,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(primary: MTheme.warningColor),
                icon: Icon(Icons.logout, size: 28),
                label: Text(tr('logout')),
                onPressed: () => alertLogout(context),
              ),
            ),
            Container(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(bool openCamera) async {
    _newImage = null;
    PickedFile? pickedFile = await ImagePicker().getImage(
        source: openCamera ? ImageSource.camera : ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _deleteImage = false;
        _newImage = File(pickedFile.path);
      }
      if (_newImage != null)
        context.read<ProfileBloc>().add(ImageProfileEvent(image: _newImage));
    });
  }

  void _removeImage() {
    setState(() {
      _deleteImage = true;
      _newImage = null;
    });
    context.read<ProfileBloc>().add(ImageProfileEvent(image: null));
  }

  void _addImage() {
    Platform.isIOS
        ? showCupertinoModalPopup(
            context: context,
            builder: (_) => _iOSPickImageSheet(),
          )
        : showModalBottomSheet(
            context: context,
            builder: (_) => _androidPickImageSheet(),
          );
  }

  Widget _androidPickImageSheet() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width - 20,
              height: 40,
              child: TextButton(
                  child: Text(tr('camera')),
                  onPressed: () {
                    Navigator.pop(context);
                    _getImage(true);
                  }),
            ),
            SizedBox(height: 8),
            Container(
              width: MediaQuery.of(context).size.width - 20,
              height: 40,
              child: TextButton(
                  child: Text(tr('gallery')),
                  onPressed: () {
                    Navigator.pop(context);
                    _getImage(false);
                  }),
            ),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            Container(
              width: MediaQuery.of(context).size.width - 20,
              height: 40,
              child: TextButton(
                child: Text(tr('cancel')),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iOSPickImageSheet() {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
            onPressed: () async {
              await _getImage(true);
              Navigator.pop(context);
            },
            child: Text(tr('camera'))),
        CupertinoActionSheetAction(
            onPressed: () async {
              await _getImage(false);
              Navigator.pop(context);
            },
            child: Text(tr('gallery'))),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(tr('cancel')),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  static void alertIOSNotGranted(BuildContext context) {
    Widget _button1() {
      return TextButton(
        child: Text(tr('ok')),
        onPressed: () {
          //todo: goto Makani settings is device settings
          Navigator.pop(context);
        },
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return (Platform.isIOS)
            ? CupertinoAlertDialog(
                title: Text(tr('notificationSettings')),
                actions: <Widget>[_button1()])
            : AlertDialog(
                title: Text(tr('notificationSettings')),
                actions: <Widget>[_button1()]);
      },
    );
  }

  static void alertLogout(BuildContext context) {
    Widget _button1() {
      return TextButton(
        child: Text(tr("logout")),
        onPressed: () {
          Navigator.pop(context); // alert
          Navigator.pop(context); // screen
          context.read<MUserCubit>().signOut();
          context.read<LoginBloc>().add(LoggingOutEvent());
        },
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return (Platform.isIOS)
            ? CupertinoAlertDialog(
                title: Text(tr("sure")), actions: <Widget>[_button1()])
            : AlertDialog(
                title: Text(tr("sure")), actions: <Widget>[_button1()]);
      },
    );
  }
}
