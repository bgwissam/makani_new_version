import 'dart:io';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static double distance(lat1, lng1, lat2, lng2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  static double radius(double zoom) {
    switch (zoom.toInt()) {
      case 20:
        return 2;
      case 19:
        return 5;
      case 18:
        return 10;
      case 17:
        return 12;
      case 16:
        return 14;
      case 15:
        return 17;
      case 14:
        return 20;
      case 13:
        return 25;
      case 12:
        return 30;
      case 11:
        return 40;
      case 10:
        return 50;
      case 9:
        return 80;
      case 8:
        return 160;
      case 7:
        return 320;
      case 6:
        return 720;
      case 5:
        return 1500;
      case 4:
        return 2000;
      case 3:
        return 5000;
      case 2:
        return 1000000;
      default:
        return 10;
    }
  }

  static void callMobile(mobile) async {
    try {
      if (await canLaunch('tel:$mobile')) await launch('tel:$mobile');
    } catch (e) {
      print('callMobile error: $e');
    }
  }

  static void sendWhatsapp(String mobile, [String message = '']) async {
    try {
      String url() {
        if (Platform.isIOS) {
          return "whatsapp://wa.me/$mobile/?text=${Uri.parse(message)}";
        } else {
          return "whatsapp://send?phone=$mobile&text=${Uri.parse(message)}";
        }
      }

      await launch(url());
    } catch (e) {
      print('sendWhatsapp error: $e');
    }
  }

  static String getDateStatus(DateTime from, DateTime to) {
    DateTime now = DateTime.now();
    String output;
    if (now.isBefore(from)) {
      // start time is in future
      output = tr('in:') + formatDuration(from.difference(now));
    } else if (now.isBefore(to)) {
      // start time is in past, end time is in future
      output = tr('to:') + formatDuration(to.difference(now));
    } else {
      // start and end time are in past
      output = tr('expired');
    }
    return output;
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd  hh:mm a')
        .format(dateTime)
        .replaceFirst('AM', tr('am'))
        .replaceFirst('PM', tr('pm'));
  }

  static String formatDuration(Duration duration) {
    var seconds = duration.inSeconds;
    final days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;
    final hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;
    final minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= minutes * Duration.secondsPerMinute;
    final List<String> tokens = [];
    if (days != 0) tokens.add(days.toString() + tr('d'));
    if (tokens.isNotEmpty || hours != 0) tokens.add(hours.toString() + tr('h'));
    if (tokens.isNotEmpty || minutes != 0)
      tokens.add(minutes.toString() + tr('m'));
    return tokens.join(':');
  }

  static void alertNeedLogin(BuildContext context) {
    Widget _button1() {
      return TextButton(
        child: Text(tr("login")),
        onPressed: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/login');
        },
      );
    }

    Widget _button2() {
      return TextButton(
        child: Text(tr("cancel")),
        onPressed: () => Navigator.pop(context),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return (Platform.isIOS)
            ? CupertinoAlertDialog(
                title: Text(tr("needLogin")),
                actions: <Widget>[_button1(), _button2()],
              )
            : AlertDialog(
                title: Text(tr("needLogin")),
                actions: <Widget>[_button1(), _button2()],
              );
      },
    );
  }

  static SnackBar snackBar(String message, [bool done = true, String? mobile]) {
    return SnackBar(
      duration: Duration(seconds: 3),
      //behavior: SnackBarBehavior.floating,
      backgroundColor: done ? Colors.green : Colors.red,
      content: Row(children: [
        Icon(
          done ? Icons.check_circle_rounded : Icons.warning_rounded,
          size: 32,
          color: Colors.white,
        ),
        SizedBox(width: 8),
        Expanded(child: Text(message)),
      ]),
      action: (mobile != null)
          ? SnackBarAction(
              label: tr('inviteButton'),
              onPressed: () => sendWhatsapp(mobile, tr('inviteMessage')),
            )
          : null,
    );
  }

  static void showSheet(BuildContext context,
      {required Widget child, required VoidCallback onClicked}) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [child],
        cancelButton: CupertinoActionSheetAction(
            child: Text(tr('done')), onPressed: onClicked),
      ),
    );
  }

  static String flag([String country = 'SA']) {
    int flagOffset = 0x1F1E6;
    int asciiOffset = 0x41;
    int firstChar = country.codeUnitAt(0) - asciiOffset + flagOffset;
    int secondChar = country.codeUnitAt(1) - asciiOffset + flagOffset;
    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }

  static String arabicNumbers(String input) {
    const arabic = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const indian = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < indian.length; i++) {
      input = input.replaceAll(indian[i], arabic[i]);
    }
    return input;
  }
}
