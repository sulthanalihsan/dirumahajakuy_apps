import 'package:dirumahajakuy/commons/database_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';

class UserLocationNotifier with ChangeNotifier {

  UserLocationNotifier(){
    print('YUHU');
  }

  Position _position;

  Position get position => _position;

  void set position(Position position) {
    _position = position;
    notifyListeners();
  }

  bool outOfRadius = false;

  void userLocationCheck(double distance) async{
    if(distance > 200){
      outOfRadius = true;
      await DatabaseHelper.db.deleteAllChallenge();
      notifyListeners();
    }else{
      outOfRadius = false;
    }
    print('userLocationCheck $distance $outOfRadius');
  }

  PickResult _selectedPlace;

  PickResult get selectedPlace => _selectedPlace;

  void set selectedPlace(PickResult pickResult) {
    _selectedPlace = pickResult;
    notifyListeners();
  }
}
