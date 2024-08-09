import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:premiumprice/lib/map_lib.dart' as map_lib;

class DefinirLocalizacaoPage extends StatefulWidget {
  const DefinirLocalizacaoPage({super.key});

  static const String routeName = '/definir-localizacao';

  @override
  State<StatefulWidget> createState() => _DefinirLocalizacaoPageState();
}

class _DefinirLocalizacaoPageState extends State<DefinirLocalizacaoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Premium Price"),
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            FlutterLocationPicker(
                initPosition: LatLong(map_lib.defaultLatitude, map_lib.defaultLongitude),
                initZoom: map_lib.defaultZoom,
                minZoomLevel: 5,
                maxZoomLevel: 18,
                //trackMyPosition: true,
                onPicked: (pickedData) {
                  Navigator.pop(context, pickedData.latLong);
                })
          ],
        ));
  }
}
