import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:papapreco/misc/map/map_lib.dart' as map_lib;

class MapProvider with ChangeNotifier {
  double _latitude = map_lib.defaultLatitude;
  double _longitude = map_lib.defaultLongitude;
  String _localizacaoString = '';
  double _distancia = 10.0;

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
    Position? p;

    try {
      p = await map_lib.currentLocation();
    } catch (_) {
      // No GPS available — desktop, emulator, or a denied permission. In those
      // cases currentLocation() completes with an error, and since main.dart
      // calls this method without awaiting it, that surfaces as an unhandled
      // async error.
      p = null;
    }

    final double latitude = p?.latitude ?? map_lib.defaultLatitude;
    final double longitude = p?.longitude ?? map_lib.defaultLongitude;

    setLatitude(latitude);
    setLongitude(longitude);

    setLocalizacaoString(
        await map_lib.reverseGeocodingString(latitude, longitude));
  }
}
