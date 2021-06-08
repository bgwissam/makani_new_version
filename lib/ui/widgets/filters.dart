import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makani/blocs/cubits/map.dart';
import 'package:makani/ui/utils/theme.dart';
import 'package:makani/ui/utils/utils.dart';

class Filters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MapState mapState = context.watch<MapCubit>().state;
    return Column(children: [
      Container(
        decoration: BoxDecoration(
          color: MTheme.unSelectedBgColor,
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        child: ToggleButtons(
          fillColor: Colors.white,
          selectedBorderColor: Colors.black.withOpacity(0.1),
          borderColor: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          constraints: BoxConstraints(
            minHeight: 42,
            minWidth: MediaQuery.of(context).size.width / 3 - 4,
          ),
          isSelected: mapState.makansFilters,
          onPressed: (index) async {
            if (mapState.user == null && index == 0)
              Utils.alertNeedLogin(context);
            else
              await context.read<MapCubit>().update(
                    debug: 'filters: makansFilters',
                    isMyMakans: false,
                    isTilesMode: false,
                    makansFilters: mapState.isMyMakans
                        ? [
                            mapState.user != null ? true : false,
                            true,
                            true,
                          ]
                        : [
                            index == 0
                                ? mapState.user != null
                                    ? !mapState.makansFilters[0]
                                    : false
                                : mapState.makansFilters[0],
                            index == 1
                                ? !mapState.makansFilters[1]
                                : mapState.makansFilters[1],
                            index == 2
                                ? !mapState.makansFilters[2]
                                : mapState.makansFilters[2],
                          ],
                    action: MapAction.Refresh,
                  );
          },
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite,
                  color: mapState.makansFilters[0]
                      ? MTheme.friendsColor
                      : MTheme.unSelectedColor,
                ),
                SizedBox(width: 1),
                Text(
                  tr('friends'),
                  style: TextStyle(
                    color: mapState.makansFilters[0]
                        ? MTheme.friendsColor
                        : MTheme.unSelectedColor,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people,
                  color: mapState.makansFilters[1]
                      ? MTheme.publicColor
                      : MTheme.unSelectedColor,
                ),
                SizedBox(width: 1),
                Text(
                  tr('public'),
                  style: TextStyle(
                    color: mapState.makansFilters[1]
                        ? MTheme.publicColor
                        : MTheme.unSelectedColor,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.handyman,
                  color: mapState.makansFilters[2]
                      ? MTheme.businessColor
                      : MTheme.unSelectedColor,
                ),
                SizedBox(width: 1),
                Text(
                  tr('business'),
                  style: TextStyle(
                    color: mapState.makansFilters[2]
                        ? MTheme.businessColor
                        : MTheme.unSelectedColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ]);
  }
}
