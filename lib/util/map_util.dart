import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapUtil {
  MapUtil._(); // Private constructor to prevent instantiation

  static Future<dynamic> reverseGeocoding(double latitude, double longitude) async {
    final http.Response response = await http.get(Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude'));

    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));

    return decodedResponse;
  }

  static Future<Position> currentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position p = await Geolocator.getCurrentPosition();

    return p;
  }
}
