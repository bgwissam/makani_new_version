import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:makani/data/models/makan.dart';
import 'package:makani/data/models/user.dart';

class Data {
  Makan makan;
  Marker marker;
  MUser owner;
  double distance; //distance from map's center

  Data(this.makan, this.marker, this.owner, this.distance);
}
