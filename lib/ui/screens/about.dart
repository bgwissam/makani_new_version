import 'package:flutter/material.dart';
import 'package:makani/ui/utils/theme.dart';

void about(context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true, // set this to true
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        //close it when click outside
        expand: false,
        builder: (_, ScrollController _controller) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: MTheme.sheetBar(),
              leading: Container(),
              centerTitle: true,
              toolbarHeight: 32,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            body: Container(
              alignment: Alignment.topCenter, //to expand the child
              color: Colors.white,
              child: SingleChildScrollView(
                //controller: _controller,
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    Text('About Makani',
                        style: Theme.of(context).textTheme.headline2),
                    SizedBox(height: 132),
                    Container(
                      child: Text(
                        'Makani is.. Makani is.. Makani is.. Makani is.. ',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: 132),
                    Container(
                      child: Text(
                        'Makani is.. Makani is.. Makani is.. Makani is.. ',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: 132),
                    Container(
                      child: Text(
                        'Makani is.. Makani is.. Makani is.. Makani is.. ',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: 132),
                    Container(
                      child: Text(
                        'Makani is.. Makani is.. Makani is.. Makani is.. ',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: 132),
                    Container(
                      child: Text(
                        'Makani is.. Makani is.. Makani is.. Makani is.. ',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
