import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:premiumprice/misc/map/map_lib.dart' as map_lib;

class MapProvider with ChangeNotifier {
  double _latitude = map_lib.defaultLatitude;
  double _longitude = map_lib.defaultLongitude;
  String _localizacaoString = '';
  double _distancia = 5.0;

  double get latitude => _latitude;
  double get longitude => _longitude;
  String get localizacaoString => _localizacaoString;
  double get distancia => _distancia;

  void setLatitude(double latitude) {
    _latitude = latitude;
    notifyListeners();
  }

  void setLongitude(double longitude) {
    _longitude = longitude;
    notifyListeners();
  }

  void setLocalizacaoString(String localizacaoString) {
    _localizacaoString = localizacaoString;
    notifyListeners();
  }

  void setDistancia(double distancia) {
    _distancia = distancia;
    notifyListeners();
  }

  Future<void> setCurrentPosition() async {
    Position? p = await map_lib.currentLocation();

    if (p != null) {
      setLatitude(p.latitude); 
      setLongitude(p.longitude);  

      String reverseGeocodingString =
        await map_lib.reverseGeocodingString(latitude, longitude);
      setLocalizacaoString(reverseGeocodingString);
    } else {
      setLatitude(map_lib.defaultLatitude); 
      setLongitude(map_lib.defaultLongitude);

      String reverseGeocodingString =
        await map_lib.reverseGeocodingString(map_lib.defaultLatitude, map_lib.defaultLongitude);
      setLocalizacaoString(reverseGeocodingString);
    }
  }
}
