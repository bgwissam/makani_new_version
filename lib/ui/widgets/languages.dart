import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

Widget languages(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(12),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(20),
      ),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(primary: Colors.white),
        child: Text(tr('otherLanguage')),
        onPressed: () {
          context.setLocale(
            context.locale.toString() == 'en_US'
                ? Locale('ar', 'SA')
                : Locale('en', 'US'),
          );
        },
      ),
    ),
  );
}
