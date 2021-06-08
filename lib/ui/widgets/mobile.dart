import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makani/blocs/cubits/friends.dart';
import 'package:makani/blocs/cubits/user.dart';
import 'package:makani/blocs/login/bloc.dart';
import 'package:makani/data/models/user.dart';
import 'package:makani/ui/utils/utils.dart';

class MobileField extends StatefulWidget {
  @override
  _MobileFieldState createState() => _MobileFieldState();
}

class _MobileFieldState extends State<MobileField> {
  final _mobileController = TextEditingController();
  FocusNode? _mobileFocus;
  int _mobileLength = 9;
  String _mobileNumber = '';
  String? _countryCode = '966';
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        context.locale.toString() == 'en_US'
            ? _countryCodeField()
            : Container(),
        _mobileField(),
        context.locale.toString() == 'en_US'
            ? Container()
            : _countryCodeField(),
      ],
    );
  }

  Widget _countryCodeField() {
    return DropdownButton(
      underline: Container(),
      value: _countryCode,
      onChanged: (dynamic value) => setState(() {
        _countryCode = value;
        _mobileController.clear(); // important for validating text field
        _mobileLength = (value == '966' || value == '971') ? 9 : 8;
      }),
      items: [
        DropdownMenuItem(value: '965', child: Text(Utils.flag('KW') + ' +965')),
        DropdownMenuItem(value: '966', child: Text(Utils.flag('SA') + ' +966')),
        DropdownMenuItem(value: '968', child: Text(Utils.flag('OM') + ' +968')),
        DropdownMenuItem(value: '971', child: Text(Utils.flag('AE') + ' +971')),
        DropdownMenuItem(value: '973', child: Text(Utils.flag('BH') + ' +973')),
        DropdownMenuItem(value: '974', child: Text(Utils.flag('QA') + ' +974')),
      ],
    );
  }

  Widget _mobileField() {
    final MUser? user = context.watch<MUserCubit>().state;
    return Container(
      width: MediaQuery.of(context).size.width / 2.5,
      child: TextFormField(
        controller: _mobileController,
        decoration: InputDecoration(
            hintText: tr('mobileNumber'), hintStyle: TextStyle(fontSize: 16)),
        style: TextStyle(fontSize: 20, letterSpacing: 2),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        autofocus: user == null,
        focusNode: _mobileFocus,
        maxLength: _mobileLength,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          bool _valid = ((value!.length == _mobileLength) &&
              ((_countryCode == '966' &&
                      Utils.arabicNumbers(value[0]) == '5') ||
                  (_countryCode != '966')));
          if (_valid && !_submitted) {
            _submitted = true;
            FocusScope.of(context).unfocus();
            _mobileNumber = '+' + _countryCode! + Utils.arabicNumbers(value);
            print('mobile user: $user ${user?.mobile}');
            if (user == null) {
              // login screen
              //without this we get error: setState() or markNeedsBuild() called during build
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                alertLogin(context, _mobileNumber);
              });
            } else {
              // friends screen
              context
                  .read<FriendsCubit>()
                  .friends(userMobile: user.mobile, addMobile: _mobileNumber);
            }
          }
          if (!_valid && value.length > 0) {
            _submitted = false;
            return tr('invalidMobile');
          } else {
            return null;
          }
        },
      ),
    );
  }

  void alertLogin(BuildContext context, String mobileNumber) {
    Widget _button1() {
      return TextButton(
        child: Text(tr('yes')),
        onPressed: () {
          Navigator.pop(context);
          context.read<LoginBloc>().add(LoggingInEvent(mobile: mobileNumber));
        },
      );
    }

    Widget _button2() {
      return TextButton(
        child: Text(tr('no')),
        onPressed: () {
          FocusScope.of(context).requestFocus(_mobileFocus);
          Navigator.pop(context);
        },
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return (Platform.isIOS)
            ? CupertinoAlertDialog(
                title: Text(tr('sendOtp')),
                actions: <Widget>[_button1(), _button2()],
              )
            : AlertDialog(
                title: Text(tr('sendOtp')),
                actions: <Widget>[_button1(), _button2()],
              );
      },
    );
  }
}
