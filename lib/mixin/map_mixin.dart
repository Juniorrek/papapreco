import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:geolocator_linux/geolocator_linux.dart';
import 'package:http/http.dart' as http;
import 'package:geoclue/geoclue.dart';

mixin MapMixin {
  /*Future<dynamic> reverseGeocoding(double latitude, double longitude) async {
    final http.Response response = await http.get(Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude'));

    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));

    return decodedResponse;
  }

  Future<String> reverseGeocodingString(double latitude, double longitude) async {
    dynamic currentGeocoding = reverseGeocoding(latitude, longitude);

    return currentGeocoding['address']['road'] + ' ' + currentGeocoding['address']['house_number'];
  }*/

  Future<Position?> currentLocation() async {
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
    } else if (permission == LocationPermission.unableToDetermine
              && Platform.isLinux) {
      /*GeolocatorLinux g = GeolocatorLinux(GeoClueManager());
      Position p = await g.getCurrentPosition();
      return p;*/
      return null;

      //return Future.error('Unable to determine.');
    } else if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position p = await Geolocator.getCurrentPosition();

    return p;
  }
}