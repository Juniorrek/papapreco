import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:premiumprice/misc/map/map_lib.dart' as map_lib;

class MapProvider with ChangeNotifier {
  double _latitude = map_lib.defaultLatitude;
  double _longitude = map_lib.defaultLongitude;
  String _localizacaoAtual = '';
  double _distancia = 5.0;

  double get latitude => _latitude;
  double get longitude => _longitude;
  String get localizacaoAtual => _localizacaoAtual;
  double get distancia => _distancia;

  void setLatitude(double latitude) {
    _latitude = latitude;
    notifyListeners();
  }

  void setLongitude(double longitude) {
    _longitude = longitude;
    notifyListeners();
  }

  void setLocalizacaoAtual(String localizacaoAtual) {
    _localizacaoAtual = localizacaoAtual;
    notifyListeners();
  }

  void setDistancia(double distancia) {
    _distancia = distancia;
    notifyListeners();
  }

  Future<void> setCurrentPosition() async {
    Position? p = await map_lib.currentLocation();

    if (p != null) {
      setLatitude(latitude); 
      setLongitude(latitude);  
    } else {
      setLatitude(map_lib.defaultLatitude); 
      setLongitude(map_lib.defaultLongitude);
    }
  }
}
