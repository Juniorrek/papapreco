import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

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
                initPosition: LatLong(-25.4950245, -49.4546094),
                initZoom: 11,
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
