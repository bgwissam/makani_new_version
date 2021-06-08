import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:makani/data/firebase/firestore.dart';
import 'package:makani/data/firebase/messaging.dart';
import 'package:makani/data/models/data.dart';
import 'package:makani/data/models/makan.dart';
import 'package:makani/data/models/user.dart';
import 'package:makani/ui/utils/theme.dart';
import 'package:makani/ui/utils/utils.dart';

enum MapAction { None, Refresh, Logout, Add, Update, Delete, Location }

class MapState {
  final String? debug;
  final List<Data> dataList;
  final Set<Marker> markersSet;
  final MUser? user;
  final String? selectedMarker;
  final List<bool> makansFilters;
  final LatLng mapCenter;
  final double mapZoom;
  final MapType mapType;
  final bool isMapTypePressed;
  final bool isGotoLocation;
  final bool isAlertLocation;
  final bool isNewMakan;
  final bool isMyMakans;
  final bool isTilesMode;
  final MapAction action;
  final bool isLoading;

  MapState({
    this.debug,
    this.dataList = const [],
    this.markersSet = const {},
    this.user,
    this.selectedMarker,
    this.makansFilters = const [false, true, true],
    //this.mapCenter = const LatLng(26.3091, 50.2278),
    this.mapCenter = const LatLng(26.15, 50.52), //temp
    this.mapZoom = 11.0,
    this.mapType = MapType.normal,
    this.isMapTypePressed = false,
    this.isGotoLocation = false,
    this.isAlertLocation = false,
    this.isNewMakan = false,
    this.isMyMakans = false,
    this.isTilesMode = false,
    this.action = MapAction.None,
    this.isLoading = false,
  });
}

class MapCubit extends Cubit<MapState> {
  Firestore firestore = Firestore();
  Messaging messaging = Messaging();

  MapCubit() : super(MapState());

  Future<void> update({
    String? debug,
    List<Data>? dataList,
    Set<Marker>? markersSet,
    MUser? user,
    String? makanId,
    List<bool>? makansFilters,
    LatLng? mapCenter,
    double? mapZoom,
    bool isMapTypePressed = false,
    bool isMyLocationPressed = false,
    bool? isGotoLocation,
    bool? isAlertLocation,
    bool? isNewMakan,
    bool? isMyMakans,
    bool? isTilesMode,
    Map<String, dynamic> values = const {},
    MapAction action = MapAction.None,
  }) async {
    emit(MapState(
      debug: debug,
      dataList: dataList ?? state.dataList,
      markersSet: markersSet ?? state.markersSet,
      user: action == MapAction.Logout ? null : user ?? state.user,
      selectedMarker:
          action == MapAction.Delete || (isTilesMode != null && !isTilesMode)
              ? null
              : makanId ?? state.selectedMarker,
      makansFilters: makansFilters ?? state.makansFilters,
      mapCenter: mapCenter ?? state.mapCenter,
      mapZoom: mapZoom ?? state.mapZoom,
      mapType: isMapTypePressed
          ? (state.mapType == MapType.normal)
              ? MapType.satellite
              : MapType.normal
          : state.isMapTypePressed || mapZoom == null
              ? state.mapType
              : mapZoom < 18
                  ? MapType.normal
                  : MapType.satellite,
      isMapTypePressed: isMapTypePressed ? true : state.isMapTypePressed,
      isGotoLocation: isGotoLocation ?? false,
      isAlertLocation: isAlertLocation ?? false,
      isNewMakan: isNewMakan ?? state.isNewMakan,
      isMyMakans: isMyMakans ?? state.isMyMakans,
      //hide tiles before deleting
      isTilesMode:
          action == MapAction.Delete ? false : isTilesMode ?? state.isTilesMode,
      action: action,
      isLoading: action != MapAction.None,
    ));

    if (action != MapAction.None) {
      String? newMakanId;
      LatLng? _location;
      bool _isLocationGranted = false;
      if (action == MapAction.Add || action == MapAction.Update) {
        if (values['category'] == 1)
          values['hobby'] = values['business'] = 0;
        else if (values['category'] == 2)
          values['business'] = 0;
        else if (values['category'] == 3) values['hobby'] = 0;
      }
      if (action == MapAction.Add) {
        values['latlng'] = state.mapCenter;
        newMakanId = await firestore.addMakan(values);
        await messaging.newMakan(newMakanId, values['latlng'], state.user!);
      } else if (action == MapAction.Update) {
        await firestore.updateMakan(values);
      } else if (action == MapAction.Delete) {
        await firestore.deleteMakan(makanId!);
      } else if (action == MapAction.Location) {
        LocationData? _data = await getMyLocation();
        if (_data != null) {
          _location = LatLng(_data.latitude!, _data.longitude!);
          _isLocationGranted = true;
        }
      }
      //don't update makans when location updated because the state still have old location
      //AND makans will be updated in the next state when onCameraIdle
      late List result;
      if (action != MapAction.Location) result = await getMakans();
      await update(
        debug: 'cubit: recursive',
        dataList: action == MapAction.Location ? state.dataList : result[0],
        markersSet: action == MapAction.Location ? state.markersSet : result[1],
        mapCenter: _location ?? state.mapCenter,
        isGotoLocation: action == MapAction.Location && _isLocationGranted,
        isAlertLocation: action == MapAction.Location &&
            !_isLocationGranted &&
            isMyLocationPressed,
        makanId: action == MapAction.Add ? newMakanId : state.selectedMarker,
      );
    }
  }

  Future<List> getMakans() async {
    List<Data> dataList = [];
    Set<Marker> markersSet = {};
    List<MUser> usersList =
        state.isMyMakans ? [state.user!] : await firestore.getAllUsers();
    List<Makan> makansList = state.isMyMakans
        ? await firestore.getMyMakans()
        : await firestore.getAllMakans(state.user, state.makansFilters);
    for (Makan makan in makansList) {
      //todo: this if has to be in DB not here!
      if (state.isMyMakans || makan.to.isAfter(DateTime.now())) {
        double radius = Utils.radius(state.mapZoom);
        double distanceFromCenter = Utils.distance(
          state.mapCenter.latitude,
          state.mapCenter.longitude,
          makan.latitude,
          makan.longitude,
        );
        //todo: this if has to be in DB not here!
        if (state.isMyMakans || distanceFromCenter < radius) {
          MUser owner =
              usersList[usersList.indexWhere((u) => u.id == makan.owner)];
          Marker marker = Marker(
            markerId: MarkerId('${makan.id}'),
            position: LatLng(makan.latitude, makan.longitude),
            icon: makan.category == 1 //friends
                ? BitmapDescriptor.defaultMarkerWithHue(
                    MTheme.friendsMarkerColor)
                : makan.category == 2 //public
                    ? BitmapDescriptor.defaultMarkerWithHue(
                        MTheme.publicMarkerColor)
                    : BitmapDescriptor.defaultMarkerWithHue(
                        MTheme.businessMarkerColor),
            infoWindow: InfoWindow(title: '${makan.id}'),
            //infoWindow: InfoWindow(title: '${owner.name ?? owner.mobile}'),
            onTap: () async {
              if (!state.isNewMakan)
                await update(
                    debug: 'cubit: marker tapped',
                    makanId: makan.id,
                    isTilesMode: true);
            },
          );
          markersSet.add(marker);
          dataList.add(Data(makan, marker, owner, distanceFromCenter));
        }
      }
    }
    dataList.sort((a, b) => a.distance.compareTo(b.distance));
    return [dataList, markersSet];
  }

  Future<LocationData?> getMyLocation() async {
    Location location = Location();
    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission(); // request permission
      if (permission != PermissionStatus.granted) return null;
    }
    // now, location is granted
    LocationData locationData = await location.getLocation();
    return locationData;
  }
}
