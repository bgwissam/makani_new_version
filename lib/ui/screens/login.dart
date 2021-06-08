import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makani/blocs/login/bloc.dart';
import 'package:makani/ui/utils/theme.dart';
import 'package:makani/ui/utils/utils.dart';
import 'package:makani/ui/widgets/languages.dart';
import 'package:makani/ui/widgets/mobile.dart';

//todo: iphone don't fill the code automatically

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("login")),
        actions: [languages(context)],
        leading: IconButton(
            icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.close),
            onPressed: () {
              context.read<LoginBloc>().add(InitialLoginEvent());
              Navigator.pop(context);
            }),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top: 64, right: 32, left: 32),
        child: BlocConsumer<LoginBloc, LoginStates>(
          builder: (context, state) {
            if (state is OtpSentState || state is OtpExceptionState) {
              return otp();
            } else if (state is LoadingLoginState ||
                state is SuccessLoginState) {
              return MTheme.loader();
            }
            //return otp();
            return MobileField();
          },
          listener: (context, state) {
            if (state is SuccessLoginState) {
              Navigator.pop(context);
            } else if (state is OtpExceptionState) {
              if (state.failedAttempts < 3) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(Utils.snackBar(tr('wrongOtp'), false));
              } else {
                context.read<LoginBloc>().add(InitialLoginEvent());
                ScaffoldMessenger.of(context)
                    .showSnackBar(Utils.snackBar(tr('checkMobile'), false));
              }
            } else if (state is ErrorLoginState) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(Utils.snackBar(tr(state.message), false));
            }
          },
        ),
      ),
    );
  }

  Widget otp() {
    return Column(children: <Widget>[
      Text(
        tr('addOtp'),
        style: Theme.of(context).textTheme.headline2,
        textAlign: TextAlign.justify,
      ),
      SizedBox(height: 16),
      Container(
        width: MediaQuery.of(context).size.width / 2,
        child: TextFormField(
          decoration: InputDecoration(
              hintText: tr('otp'), hintStyle: TextStyle(fontSize: 18)),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32, letterSpacing: 8),
          keyboardType: TextInputType.number,
          autofocus: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          maxLength: 6,
          validator: (value) {
            if (value!.length == 6 && !_submitted) {
              _submitted = true;
              FocusScope.of(context).unfocus();
              context
                  .read<LoginBloc>()
                  .add(OtpVerifyEvent(smsCode: Utils.arabicNumbers(value)));
            } else if (value.length < 6 && _submitted) {
              _submitted = false;
            }
            return null;
          },
        ),
      ),
    ]);
  }
}
