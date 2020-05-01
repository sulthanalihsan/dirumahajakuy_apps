import 'dart:convert';

import 'package:dirumahajakuy/commons/pref_helper.dart';
import 'package:dirumahajakuy/const/app_constant.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<double> userDistanceFromHome(Position position) async {
    double distance;
    try {
      distance =
          await PrefHelper.getPref(AppConst.locationPref).then((result) async {
        return await Geolocator().distanceBetween(
            position.latitude,
            position.longitude,
            jsonDecode(result)['latitude'],
            jsonDecode(result)['longitude']);
      });
    } catch (e) {
      print("ERROR KITA $e");
    }
    return distance;
  }
}
