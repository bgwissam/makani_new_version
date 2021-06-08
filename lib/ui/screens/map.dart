import 'dart:io';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:makani/blocs/cubits/notifications.dart';
import 'package:makani/blocs/cubits/user.dart';
import 'package:makani/blocs/cubits/map.dart';
import 'package:makani/blocs/login/bloc.dart';
import 'package:makani/data/models/user.dart';
import 'package:makani/ui/utils/theme.dart';
import 'package:makani/ui/utils/utils.dart';
import 'package:makani/ui/widgets/buttons.dart';
import 'package:makani/ui/widgets/filters.dart';
import 'package:makani/ui/widgets/tiles.dart';

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  final PageController tilesController =
      PageController(initialPage: 0, viewportFraction: 0.8);
  final Completer<GoogleMapController> mapCompleter = Completer();
  late GoogleMapController mapController;
  bool isInitial = true;
  MUser? user;

  // @override
  // void initState() {
  //   isInitial = true;
  //   super.initState();
  // }

  @override
  void dispose() {
    tilesController
        .dispose(); //declared here to dispose it here in stateFull class
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late LatLng _position;
    late double _zoom;
    late int _pixels;

    return Scaffold(
      body: Stack(children: [
        BlocListener<MUserCubit, MUser?>(
          listener: (context, mUser) async {
            print('map MUserCubit.user: $mUser ${mUser?.mobile}');
            user = mUser;
            await context.read<MapCubit>().update(
                  debug: 'map: update user data',
                  user: mUser,
                  //this sets user to null. Without this user will get its previous state value.
                  action: (mUser == null) ? MapAction.Logout : MapAction.None,
                );
          },
          child: Container(),
        ),
        BlocListener<LoginBloc, LoginStates>(
          listener: (context, loginState) async {
            if (loginState is SuccessLoginState) {
              await context.read<MapCubit>().update(
                    debug: 'map: login',
                    makansFilters: [true, true, true],
                    user: user,
                    action: MapAction.Refresh,
                  );
              ScaffoldMessenger.of(context)
                  .showSnackBar(Utils.snackBar(tr('loginSuccess')));
            } else if (loginState is SuccessLogoutState) {
              await context.read<MapCubit>().update(
                    debug: 'map: logout',
                    makansFilters: [false, true, true],
                    isMyMakans: false,
                    action: MapAction.Logout, //this sets user to null
                  );
              ScaffoldMessenger.of(context)
                  .showSnackBar(Utils.snackBar(tr('logoutSuccess')));
            }
          },
          child: Container(),
        ),
        BlocListener<NotificationsCubit, Message>(
          listener: (context, message) {
            if (message.id != null) {
              alertNotification(context, message);
              context.read<NotificationsCubit>().reset();
            }
          },
          child: Container(),
        ),
        BlocConsumer<MapCubit, MapState>(
          listener: (context, mapState) async {
            if (mapState.isGotoLocation)
              await mapController
                  .animateCamera(CameraUpdate.newLatLng(mapState.mapCenter));
            else if (mapState.isAlertLocation)
              alertLocation(context);
            else if (mapState.action == MapAction.Add)
              ScaffoldMessenger.of(context)
                  .showSnackBar(Utils.snackBar(tr('makanAdded')));
            else if (mapState.action == MapAction.Update)
              ScaffoldMessenger.of(context)
                  .showSnackBar(Utils.snackBar(tr('makanUpdated')));
            else if (mapState.action == MapAction.Delete)
              ScaffoldMessenger.of(context)
                  .showSnackBar(Utils.snackBar(tr('makanDeleted')));
          },
          builder: (context, mapState) {
            debug(mapState);
            var map = GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: mapState.mapCenter, zoom: mapState.mapZoom),
              mapType: mapState.mapType,
              markers: mapState.markersSet,
              myLocationEnabled: true,
              rotateGesturesEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) async {
                mapCompleter.complete(controller);
                mapController = await mapCompleter.future;
              },
              onCameraMove: (CameraPosition position) {
                _position = position.target;
                _zoom = position.zoom;
              },
              onCameraIdle: () async {
                if (isInitial) {
                  isInitial = false;
                  await context.read<MapCubit>().update(
                        debug: 'map: initial',
                        makansFilters: [user != null, true, true],
                        user: user,
                        action: MapAction.Location,
                      );
                } else if (!mapState.isTilesMode) {
                  await context.read<MapCubit>().update(
                        debug: 'map: onCameraIdle',
                        mapCenter: _position,
                        mapZoom: _zoom,
                        action: (!mapState.isTilesMode &&
                                !mapState.isMyMakans &&
                                !mapState.isNewMakan)
                            ? MapAction.Refresh
                            : MapAction.None,
                      );
                }
              },
              onTap: (_) async {
                // onTap means on map not on markers
                if (mapState.isTilesMode)
                  await context.read<MapCubit>().update(
                        debug: 'map: on map tapped: isTilesMode: false',
                        isTilesMode: false,
                      );
              },
            );
            return Stack(children: [
              Listener(
                //hide tiles when user moves the map. 5 is best practice.
                onPointerDown: (_) => _pixels = 0,
                onPointerMove: (_) async {
                  if (++_pixels == 5 && mapState.isTilesMode) {
                    mapController.hideMarkerInfoWindow(
                        MarkerId(mapState.selectedMarker!));
                    await context.read<MapCubit>().update(
                          debug: 'map: on map moved: isTilesMode: false',
                          isTilesMode: false,
                        );
                  }
                },
                child: map,
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                top: mapState.isNewMakan ? -100 : 48,
                width: MediaQuery.of(context).size.width,
                child: Filters(),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                bottom: mapState.isTilesMode ? -180 : 48,
                width: MediaQuery.of(context).size.width,
                child: Buttons(),
              ),
              if (mapState.dataList.length > 0)
                AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  bottom: mapState.isTilesMode ? 36 : -150,
                  height: 150,
                  width: MediaQuery.of(context).size.width,
                  child: Tiles(mapController, tilesController),
                ),
              if (mapState.isNewMakan)
                Center(
                    child:
                        Icon(Icons.my_location, size: 42, color: Colors.red)),
              if (mapState.isLoading) MTheme.loader(true),
            ]);
          },
        ),
      ]),
    );
  }

  void debug(MapState mapState) {
    print(
        '------------------------ MapCubit New State: ------------------------');
    print('------------> debug: ${mapState.debug}');
    print('------------> dataList: ${mapState.dataList.length}');
    print('------------> markersSet: ${mapState.markersSet.length}');
    print('------------> user: ${mapState.user} ${mapState.user?.mobile}');
    print('------------> selectedMarker: ${mapState.selectedMarker}');
    print('------------> makansFilters: ${mapState.makansFilters}');
    print('------------> mapCenter: ${mapState.mapCenter}');
    print('------------> mapZoom: ${mapState.mapZoom}');
    print('------------> mapType: ${mapState.mapType}');
    print('------------> isMapTypePressed: ${mapState.isMapTypePressed}');
    print('------------> isGotoLocation: ${mapState.isGotoLocation}');
    print('------------> isAlertLocation: ${mapState.isAlertLocation}');
    print('------------> isNewMakan: ${mapState.isNewMakan}');
    print('------------> isMyMakans: ${mapState.isMyMakans}');
    print('------------> isTilesMode: ${mapState.isTilesMode}');
    print('------------> action: ${mapState.action}');
    print('------------> isLoading: ${mapState.isLoading}');
  }

  void alertLocation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return (Platform.isIOS)
            ? CupertinoAlertDialog(
                title: Text(tr("alertMyLocationTitle")),
                content: Text(tr("alertMyLocationDesc")),
                actions: <Widget>[
                  TextButton(
                      child: Text(tr("ok")),
                      onPressed: () => Navigator.pop(context)),
                ],
              )
            : AlertDialog(
                title: Text(tr("alertMyLocationTitle")),
                content: Text(tr("alertMyLocationDesc")),
                actions: <Widget>[
                  TextButton(
                      child: Text(tr("ok")),
                      onPressed: () => Navigator.pop(context)),
                ],
              );
      },
    );
  }

  void alertNotification(BuildContext context, Message message) {
    Widget _button1() {
      return TextButton(
        child: Text('go'),
        onPressed: () async {
          Navigator.pop(context);
          await context.read<MapCubit>().update(
                debug: 'map: notification Refresh',
                action: MapAction.Refresh,
              ); // wait for refresh
          await mapController.animateCamera(CameraUpdate.newLatLngZoom(
            LatLng(message.latlng!.latitude, message.latlng!.longitude),
            13,
          ));
          //after refreshing, show tiles and MarkerInfoWindow
          await context.read<MapCubit>().update(
                debug: 'map: notification isTilesMode',
                makanId: message.id,
                isTilesMode: true,
              );
        },
      );
    }

    Widget _button2() {
      return TextButton(
        child: Text('cancel'),
        onPressed: () => Navigator.pop(context),
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return (Platform.isIOS)
            ? CupertinoAlertDialog(
                title: Text(message.title!),
                content: Text(message.body!),
                actions: <Widget>[_button1(), _button2()],
              )
            : AlertDialog(
                title: Text(message.title!),
                content: Text(message.body!),
                actions: <Widget>[_button1(), _button2()],
              );
      },
    );
  }
}
