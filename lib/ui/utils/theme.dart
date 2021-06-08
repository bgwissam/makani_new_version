//Source: https://api.flutter.dev/flutter/material/TextTheme-class.html
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:makani/ui/utils/utils.dart';

class MTheme {
  static final Color textBgColor = Colors.lightBlue[100]!;
  static final Color formLabel = Colors.black.withOpacity(0.5);
  static final Color warningColor = Colors.red[800]!;
  static final Color doneColor = Colors.green;
  static final Color unSelectedColor = Colors.grey[600]!;
  static final Color unSelectedBgColor = Colors.grey[300]!;
  static final Color friendsColor = Colors.teal;
  static final Color publicColor = Colors.purple;
  static final Color businessColor = Colors.orange[900]!;
  static final double friendsMarkerColor = BitmapDescriptor.hueCyan;
  static final double publicMarkerColor = BitmapDescriptor.hueViolet;
  static final double businessMarkerColor = BitmapDescriptor.hueOrange;

  static ThemeData defaultTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.lightBlue[800],
      accentColor: Colors.cyan[600],
      appBarTheme: AppBarTheme(elevation: 8),
      //iconTheme: IconThemeData(color: Colors.red, size: 80.0),//filters
      //buttonColor: Colors.red,

      //todo: I think no need for this
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            // textStyle: TextStyle(
            //   color: Colors.deepOrange,
            //   fontSize: 30,
            //   fontWeight: FontWeight.bold,
            // ),
            ),
      ),
      //todo
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            // padding: EdgeInsets.all(15),
            // textStyle: TextStyle(
            //   fontSize: 30,
            // ),
            ),
      ),
      //todo
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: StadiumBorder(),
          minimumSize: Size(0, 40),
          //padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          // primary: Colors.orange, // background color
          // textStyle: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
        ),
      ),

      buttonTheme: ButtonThemeData(
        shape: StadiumBorder(),
        height: 40,
        buttonColor: Colors.white, //button's BG color
        textTheme: ButtonTextTheme.primary, //button's text color
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: MTheme.warningColor,
        actionTextColor: Colors.yellow,
      ),

      textTheme: TextTheme(
        headline1: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        headline2: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        headline3: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        // used for links with buttons
        headline4: TextStyle(
          fontSize: 13.0,
          color: Colors.lightBlue[800],
        ),
        subtitle2: TextStyle(
          fontSize: 16.0,
          color: Colors.lightBlue[800],
          decoration: TextDecoration.underline,
        ),
        // this is the default text
        bodyText2: TextStyle(
          fontSize: 16.0,
        ),
        bodyText1: TextStyle(
          fontSize: 14.0,
        ),
        button: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  static Widget loader([bool active = false]) {
    return Container(
      alignment: Alignment.center,
      color: active ? null : Colors.white.withOpacity(0.3),
      child: Platform.isIOS
          ? CupertinoActivityIndicator(radius: 24)
          : CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color?>(Colors.red[300])),
    );
  }

  static Widget error({message = '', file = '', error = ''}) {
    return Container(
      alignment: Alignment.center,
      color: Colors.red.withOpacity(0.3),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_rounded, color: Colors.red, size: 64),
          SizedBox(height: 10),
          Text(file, style: TextStyle(color: Colors.black54)),
          Text(error, style: TextStyle(color: Colors.black54)),
          SizedBox(height: 30),
          (message == '') ? Text(tr('errorMessage')) : Text(message),
          SizedBox(height: 30),
          Text(tr('errorContactUs')),
          InkWell(
            onTap: () => Utils.sendWhatsapp(
              '+966555884000',
              'message: $message -- file: $file -- error: $error',
            ),
            child: Text(
              '966555884000',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  static Widget sheetBar() {
    return Container(
      height: 6,
      width: 128,
      margin: EdgeInsets.all(6),
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.all(Radius.circular(4)),
          border: Border.all(color: Colors.black.withOpacity(0.2))),
    );
  }
}
