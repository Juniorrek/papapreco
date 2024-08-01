import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ListarProdutosMapaPage extends StatefulWidget {
  const ListarProdutosMapaPage({super.key});

  static const String routeName = '/produtos/mapa';

  @override
  State<StatefulWidget> createState() => _ListarProdutosMapaPageState();
}

class _ListarProdutosMapaPageState extends State<ListarProdutosMapaPage> {
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
        appBar: AppBar(title: const Text("Premium Price")),
        body: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(-25.469814, -49.235499),
                initialZoom: 19,
                cameraConstraint: CameraConstraint.contain(
                  bounds: LatLngBounds(
                    const LatLng(-90, -180),
                    const LatLng(90, 180),
                  ),
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'br.com.premiumprice',
                  // Plenty of other options available!
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(-25.469680, -49.235317),
                      width: 180,
                      height: 180,
                      child: Icon(Icons.location_on, size: 50,),
                    ),
                  ],
                ),
              ],
            )
          ],
        ));
  }
}
