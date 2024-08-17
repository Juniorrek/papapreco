import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

double defaultLatitude = -25.4284;
double defaultLongitude = -49.2733;
double defaultZoom = 18;

Future<dynamic> geocoding(String query) async {
  final http.Response response = await http.get(Uri.parse(
      'https://nominatim.openstreetmap.org/search?format=json&q=$query'));

  var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));

  return decodedResponse;
}

Future<dynamic> reverseGeocoding(double latitude, double longitude) async {
  final http.Response response = await http.get(Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude'));

  var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));

  return decodedResponse;
}

Future<String> reverseGeocodingString(double latitude, double longitude) async {
  dynamic currentGeocoding = await reverseGeocoding(latitude, longitude);

  if (currentGeocoding is Map<String, dynamic>) {
    if (currentGeocoding['address'] != null &&
        currentGeocoding['address']['road'] != null &&
        currentGeocoding['address']['house_number'] != null) {
      return currentGeocoding['address']['road'] +
          ' ' +
          currentGeocoding['address']['house_number'];
    } else if (currentGeocoding['address'] != null &&
        currentGeocoding['address']['road'] != null &&
        currentGeocoding['address']['neighbourhood'] != null) {
      return currentGeocoding['address']['road'] +
          ' ' +
          currentGeocoding['address']['neighbourhood'];
    } else {
      return currentGeocoding['display_name'];
    }
  }
  return 'Erro ao buscar localização!';
}

Future<String> reverseGeocodingShop(double latitude, double longitude) async {
  dynamic currentGeocoding = await reverseGeocoding(latitude, longitude);

  if (currentGeocoding is Map<String, dynamic>) {
    if (currentGeocoding['address'] != null &&
        currentGeocoding['address']['shop'] != null) {
      return currentGeocoding['address']['shop'];
    } else if (currentGeocoding['class'] == 'shop' && currentGeocoding['name'] != null) {
      return currentGeocoding['name'];
    } else if (currentGeocoding['address'] != null &&
        currentGeocoding['address']['road'] != null) {
      return currentGeocoding['address']['road'];
    } else {
      return currentGeocoding['display_name'];
    }
  }
  return 'Erro ao buscar localização!';
}

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
  } else if (permission == LocationPermission.unableToDetermine &&
      Platform.isLinux) {
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
