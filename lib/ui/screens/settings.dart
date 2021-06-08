import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:makani/ui/screens/profile.dart';
import 'package:makani/ui/screens/friends.dart';
import 'package:makani/ui/widgets/languages.dart';

class Settings extends StatefulWidget {
  final isFriends;

  const Settings({Key? key, this.isFriends = false}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings>
    with SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFriends) tabController!.animateTo(1);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [languages(context)],
          leading: IconButton(
            icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            controller: tabController,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.person), text: tr('myProfile')),
              Tab(icon: Icon(Icons.people), text: tr('myFriends')),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            Profile(tabController),
            Friends(),
          ],
        ),
      ),
    );
  }
}
