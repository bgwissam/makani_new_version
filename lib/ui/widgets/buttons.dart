import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makani/blocs/cubits/map.dart';
import 'package:makani/ui/screens/about.dart';
import 'package:makani/ui/utils/theme.dart';
import 'package:makani/ui/utils/utils.dart';

class Buttons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MapState mapState = context.watch<MapCubit>().state;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(children: [
          FloatingActionButton(
            mini: true,
            heroTag: 'myLocation',
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.my_location, size: 24),
            onPressed: () async => await context.read<MapCubit>().update(
                  debug: 'buttons: myLocation',
                  action: MapAction.Location,
                  isMyLocationPressed: true,
                ),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            mini: true,
            heroTag: 'changeMapType',
            //without this MultiProvider gives error
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).primaryColor,
            child: Icon(Icons.map, size: 24),
            onPressed: () async => await context.read<MapCubit>().update(
                  debug: 'buttons: isMapTypePressed',
                  isMapTypePressed: true,
                ),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'newMakan',
            //without this MultiProvider gives error
            backgroundColor:
                mapState.user != null ? Colors.white : MTheme.unSelectedBgColor,
            foregroundColor: mapState.user != null
                ? Theme.of(context).primaryColor
                : MTheme.unSelectedColor,
            child: Icon(Icons.add_location, size: 32),
            onPressed: () async {
              if (mapState.user != null) {
                await context.read<MapCubit>().update(
                      debug: 'buttons: isNewMakan: true',
                      isNewMakan: true,
                    );
                showBottomSheet(
                  context: context,
                  backgroundColor: Color(0x00000000),
                  builder: (context) => marker(context),
                ).closed.then((_) async => await
                    //this will be called whenever the sheet closing
                    context.read<MapCubit>().update(
                          debug: 'buttons: isNewMakan: false',
                          isNewMakan: false,
                        ));
              } else {
                Utils.alertNeedLogin(context);
              }
            },
          ),
        ]),
        FloatingActionButton.extended(
          heroTag: 'myMakans',
          icon: Icon(Icons.location_history, size: 32),
          label: Text(tr('myMakans')),
          backgroundColor:
              mapState.isMyMakans ? Colors.white : MTheme.unSelectedBgColor,
          foregroundColor: mapState.isMyMakans
              ? Theme.of(context).primaryColor
              : MTheme.unSelectedColor,
          onPressed: () async {
            if (mapState.user != null) {
              await context.read<MapCubit>().update(
                    debug: 'buttons: myMakans',
                    isMyMakans: !mapState.isMyMakans,
                    makansFilters: [
                      mapState.isMyMakans,
                      mapState.isMyMakans,
                      mapState.isMyMakans
                    ],
                    action: MapAction.Refresh,
                  );
            } else {
              Utils.alertNeedLogin(context);
            }
          },
        ),
        Column(children: [
          FloatingActionButton(
            mini: true,
            heroTag: 'about',
            // without this MultiProvider gives error
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).primaryColor,
            child: Icon(Icons.info_outline, size: 24),
            onPressed: () => about(context),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'settings',
            // without this MultiProvider gives error
            backgroundColor:
                mapState.user != null ? Colors.white : MTheme.unSelectedBgColor,
            foregroundColor: mapState.user != null
                ? Theme.of(context).primaryColor
                : MTheme.unSelectedColor,
            child: Icon(Icons.settings, size: 32),
            onPressed: () {
              mapState.user != null
                  ? Navigator.pushNamed(context, '/profile')
                  : Utils.alertNeedLogin(context);
            },
          ),
        ]),
      ],
    );
    // });
  }

  Widget marker(context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [BoxShadow(blurRadius: 8.0)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(tr("moveMarker")),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton.icon(
                label: Text(tr("cancel")),
                icon: Icon(Icons.arrow_downward),
                style: OutlinedButton.styleFrom(
                    minimumSize:
                        Size(MediaQuery.of(context).size.width * 0.3, 36)),
                onPressed: () => Navigator.pop(context),
              ),
              OutlinedButton.icon(
                label: Text(tr("next")),
                icon: Icon(Icons.arrow_forward),
                style: OutlinedButton.styleFrom(
                    minimumSize:
                        Size(MediaQuery.of(context).size.width * 0.3, 36)),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/add');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
