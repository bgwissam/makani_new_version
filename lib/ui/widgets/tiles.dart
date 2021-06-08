//source:
//https://github.com/rajayogan/flutter-googlemapeffects/blob/master/lib/main.dart
//https://youtu.be/CjhXyY_92xU

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:makani/blocs/cubits/map.dart';
import 'package:makani/data/models/makan.dart';
import 'package:makani/data/models/user.dart';
import 'package:makani/ui/screens/details.dart';
import 'package:makani/ui/utils/theme.dart';
import 'package:makani/ui/utils/utils.dart';
import 'package:makani/ui/widgets/photo.dart';

class Tiles extends StatelessWidget {
  final PageController tilesController;
  final GoogleMapController mapController;

  Tiles(this.mapController, this.tilesController);

  @override
  Widget build(BuildContext context) {
    bool _isUserScrolling = false;
    return BlocConsumer<MapCubit, MapState>(
      listener: (context, state) async {
        if (!_isUserScrolling &&
            state.isTilesMode &&
            state.selectedMarker != null) {
          // marker has been tapped or we have a new makan
          int i = state.dataList
              .indexWhere((d) => d.makan.id == state.selectedMarker);
          // without this duration we get error says showInfoWindow called with invalid markerId
          await Future.delayed(Duration(milliseconds: 10));
          await mapController
              .showMarkerInfoWindow(MarkerId('${state.selectedMarker}'));
          scrollToTile(i);
        }
      },
      builder: (context, mapState) {
        return Listener(
          onPointerDown: (_) => _isUserScrolling = true,
          child: PageView.builder(
            controller: tilesController,
            itemCount: mapState.dataList.length,
            itemBuilder: (BuildContext context, int i) {
              return tile(context, i, mapState.dataList[i].makan,
                  mapState.dataList[i].owner);
            },
            onPageChanged: (i) async {
              if (_isUserScrolling) {
                //tile has been tapped or scrolled by user (_isUserScrolling is true)
                mapController.animateCamera(CameraUpdate.newLatLngZoom(
                  LatLng(mapState.dataList[i].makan.latitude,
                      mapState.dataList[i].makan.longitude),
                  13,
                ));
                mapController.showMarkerInfoWindow(
                    MarkerId('${mapState.dataList[i].makan.id}'));
                await context.read<MapCubit>().update(
                      debug: 'tiles: onPageChanged',
                      makanId: mapState.dataList[i].makan.id,
                    );
              }
            },
          ),
        );
      },
    );
  }

  Widget tile(BuildContext context, int index, Makan makan, MUser owner) {
    return AnimatedBuilder(
      animation: tilesController,
      builder: (BuildContext context, Widget? widget) {
        double value = 1;
        if (tilesController.position.haveDimensions) {
          value = tilesController.page! - index;
          value = (1 - (value.abs() * 0.3) + 0.01).clamp(0.0, 1.0);
        }
        return Center(
          child: Container(
            height: Curves.easeInOut.transform(value) * 130.0,
            width: Curves.easeInOut.transform(value) * 350.0,
            child: widget,
          ),
        );
      },
      child: GestureDetector(
        onVerticalDragUpdate: (gesture) async {
          if (gesture.delta.dy > 0) {
            mapController.hideMarkerInfoWindow(MarkerId(makan.id));
            await context
                .read<MapCubit>()
                .update(debug: 'tiles: isTilesMode: false', isTilesMode: false);
          } else if (tilesController.page!.floor() == index &&
              gesture.delta.dy < 0) Details(context, makan, owner).sheet();
        },
        onTap: () async {
          if (tilesController.page!.floor() == index)
            Details(context, makan, owner).sheet();
          else
            scrollToTile(index);
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  offset: Offset(0, 4),
                  blurRadius: 4,
                ),
              ]),
          child: Row(children: [
            Container(
              width: 120,
              child: photo(
                130,
                url: owner.image,
                radius: context.locale.toString() == 'ar_SA' ? 'right' : 'left',
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          makan.title,
                          style: Theme.of(context).textTheme.headline3,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          Utils.getDateStatus(makan.from, makan.to),
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    color: MTheme.unSelectedColor,
                                  ),
                          maxLines: 1,
                        ),
                        Text(
                          makan.id,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                    Flexible(
                      //important for text overflow
                      child: Text(
                        makan.details.replaceAll("\n", " "),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void scrollToTile(int index) {
    tilesController.animateToPage(
      index,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOutCubic,
    );
  }
}
