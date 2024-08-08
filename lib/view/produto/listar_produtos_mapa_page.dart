import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/repositories/produto_repository.dart';
import 'dart:math';

import 'package:premiumprice/util/map_util.dart';

class ListarProdutosMapaPage extends StatefulWidget {
  final String nomeProduto;
  final double latitude;
  final double longitude;

  const ListarProdutosMapaPage(
      {super.key,
      required this.nomeProduto,
      required this.latitude,
      required this.longitude});

  static const String routeName = '/produtos/mapa';

  @override
  State<StatefulWidget> createState() => _ListarProdutosMapaPageState();
}

class _ListarProdutosMapaPageState extends State<ListarProdutosMapaPage> {
  final ProdutoRepository _repository = ProdutoRepository();
  List<Marker> _markers = <Marker>[];
  List<Produto> _produtos = <Produto>[];

  final MapController _mapController = MapController();
  

  @override
  void initState() {
    super.initState();

    _repository.buscarPorNome(widget.nomeProduto).then((produtos) {
        setState(() {
            _produtos = produtos;

            _markers = _gerarMarkers(_produtos);
        });

        LatLng centroide = _calcularCentroideProdutos(_produtos);
        _mapController.move(centroide, MapUtil.defaultZoom);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  LatLng _calcularCentroideProdutos(List<Produto> produtos) {
    double latitude = (produtos.map<double>((p) => p.latitude).reduce(max)
                    + produtos.map<double>((p) => p.latitude).reduce(min)) / 2;

    double longitude = (produtos.map<double>((p) => p.longitude).reduce(max)
                    + produtos.map<double>((p) => p.longitude).reduce(min)) / 2;

    return LatLng(latitude, longitude);
  }

  List<Marker> _gerarMarkers(List<Produto> produtos) {
    List<Marker> markers = <Marker>[];

    for (final produto in produtos) {
      markers.add(Marker(
          point: LatLng(produto.latitude, produto.longitude),
          width: 180,
          height: 180,
          child: GestureDetector(
              child: const Icon(
                Icons.location_on,
                size: 50,
              ),
              onTap: () {
                print(produto.nome);
              }
            )));
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Premium Price")),
        body: Stack(
          children: [
            FlutterMap(
                mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(MapUtil.defaultLatitude, MapUtil.defaultLongitude),
                initialZoom: MapUtil.defaultZoom,
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
                  markers: _markers,
                ),
              ],
            )
          ],
        ));
  }
}
