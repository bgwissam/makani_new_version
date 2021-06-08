import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    print('=====> Create: ${bloc.runtimeType} $bloc');
    super.onCreate(bloc);
  }

  // @override
  // void onClose(BlocBase bloc) {
  //   print('=====> Close: ${bloc.runtimeType} $bloc');
  //   super.onClose(bloc);
  // }

  @override
  void onEvent(Bloc bloc, Object? event) {
    print('=====> Event: ${bloc.runtimeType} $event');
    super.onEvent(bloc, event);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    print('=====> Change: ${bloc.runtimeType} $change');
    if (bloc.runtimeType.toString() == 'MapCubit') {
      // this is not helpful because it's print current state not the new one!
      // print('---> mapCenter: ${bloc.state.mapCenter}');
      // print('---> mapZoom: ${bloc.state.mapZoom}');
      // print('---> mapType: ${bloc.state.mapType}');
      // print('---> isUserControlMapType: ${bloc.state.isUserControlMapType}');
      // print('---> isNewMakan: ${bloc.state.isNewMakan}');
      // print('---> isMyMakans: ${bloc.state.isMyMakans}');
      // print('---> isTilesMode: ${bloc.state.isTilesMode}');
      // print('---> makansFilters: ${bloc.state.makansFilters}');
      // print('---> selectedMarker: ${bloc.state.selectedMarker}');
    }
    super.onChange(bloc, change);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('=====> Error: ${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
