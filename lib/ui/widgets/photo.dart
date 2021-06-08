import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:makani/ui/utils/theme.dart';

Widget photo(double size, {File? path, String? url, String? radius}) {
  return ClipRRect(
    borderRadius: radius == 'all'
        ? BorderRadius.circular(16)
        : radius == 'right'
            ? BorderRadius.only(
                bottomRight: Radius.circular(8),
                topRight: Radius.circular(8),
              )
            : radius == 'left'
                ? BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  )
                : radius == 'top'
                    ? BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      )
                    : BorderRadius.circular(0),
    child: Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: MTheme.unSelectedBgColor,
        image: DecorationImage(
          image: AssetImage('assets/images/person.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: (path != null)
          ? Image.file(path, fit: BoxFit.cover)
          : (url == '' || url == null)
              ? null
              : CachedNetworkImage(
                  imageUrl: url,
                  placeholder: (context, url) => MTheme.loader(),
                  fit: BoxFit.cover,
                ),
    ),
  );
}
