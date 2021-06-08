/*
//todo-Final:
 - Remember to restrict the API key before using it in production:
   developers.google.com/maps/documentation/android-sdk/get-api-key#restrict_key
   https://codelabs.developers.google.com/codelabs/friendlyeats-flutter/#13
 - Monitor or close these services from Google Cloud:
   "Places, Geolocation, & Geocoding", because they could be costly.
 - Check 'race condition' as mentioned at the end of video: youtu.be/DqJ_KjFzL9I
 - Remove all un-used code from the project, like print.
 - Dispose every stream - Abdullah: we don't need to close the stream builders.
 - 'Wakelock.enable()' is for testing only, remove it before production.
 - Change the mobile number in MakaniTheme().error()

//todo-Later:
 - show name from my contacts like STC App

Good Examples for this project:
 - Project: /Users/khalid/AndroidStudioProjects/samples-master/place_tracker
 - Tiles: https://youtu.be/lNqEfnnmoHk or https://youtu.be/CjhXyY_92xU
 - Filter markers by distance: https://youtu.be/ZE07QCPt42c
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:makani/blocs/cubits/user.dart';
import 'package:makani/blocs/cubits/map.dart';
import 'package:makani/blocs/cubits/friends.dart';
import 'package:makani/blocs/cubits/notifications.dart';
import 'package:makani/blocs/login/bloc.dart';
import 'package:makani/blocs/profile/bloc.dart';
import 'package:makani/ui/utils/bloc_observer.dart';
import 'package:makani/ui/utils/theme.dart';
import 'package:makani/ui/screens/login.dart';
import 'package:makani/ui/screens/map.dart';
import 'package:makani/ui/screens/new.dart';
import 'package:makani/ui/screens/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(EasyLocalization(
      path: 'assets/langs',
      supportedLocales: [Locale('en', 'US'), Locale('ar', 'SA')],
      child: Makani()));
}

class Makani extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FocusScopeNode _focusScope = FocusScope.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MUserCubit()..user()),
        BlocProvider(create: (_) => MapCubit()),
        BlocProvider(create: (_) => LoginBloc()),
        BlocProvider(create: (_) => NotificationsCubit()),
        BlocProvider(create: (_) => ProfileBloc()),
        BlocProvider(create: (_) => FriendsCubit()..friends()),
      ],
      child: GestureDetector(
        onTap: () {
          // hide keyboard when click outside input fields
          if (!_focusScope.hasPrimaryFocus && _focusScope.focusedChild != null)
            FocusManager.instance.primaryFocus!.unfocus();
        },
        child: NotificationListener<ScrollNotification>(
          // hide keyboard when scroll
          onNotification: (n) {
            if (n is UserScrollNotification)
              FocusManager.instance.primaryFocus!.unfocus();
            return false;
          },
          child: MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            debugShowCheckedModeBanner: false,
            onGenerateRoute: routes,
            theme: MTheme.defaultTheme(),
          ),
        ),
      ),
    );
  }

  static Route<dynamic> routes(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => Login());
      case '/add':
        return MaterialPageRoute(builder: (_) => New());
      case '/update':
        return MaterialPageRoute(builder: (_) => New(isUpdate: true));
      case '/profile':
        return MaterialPageRoute(builder: (_) => Settings());
      case '/friends':
        return MaterialPageRoute(builder: (_) => Settings(isFriends: true));
      default: // '/map'
        return MaterialPageRoute(builder: (_) => Map());
    }
  }
}
