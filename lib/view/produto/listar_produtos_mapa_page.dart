import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:premiumprice/misc/auth/map_provider.dart';
import 'package:premiumprice/misc/map/tile_providers.dart';
import 'package:premiumprice/model/produto.dart';
import 'dart:math';
import 'package:premiumprice/misc/map/map_lib.dart' as map_lib;
import 'package:premiumprice/routes/routes.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ListarProdutosMapaPage extends StatefulWidget {
  final List<Produto> produtos;
  final bool fromDetail;

  const ListarProdutosMapaPage(
      {super.key, required this.produtos, required this.fromDetail});

  static const String routeName = '/produtos/mapa';

  @override
  State<StatefulWidget> createState() => _ListarProdutosMapaPageState();
}

class _ListarProdutosMapaPageState extends State<ListarProdutosMapaPage> {
  final DateFormat _dataFormatter = DateFormat('dd/MM/yyyy – kk:mm');
  List<Marker> _markers = <Marker>[];

  final MapController _mapController = MapController();

  bool isLoading = false;

   final NumberFormat _moneyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();

    _gerarMarkers(widget.produtos);
  }

  @override
  void dispose() {
    super.dispose();
  }

  LatLng _calcularCentroideProdutos(List<Produto> produtos) {
    double latitude = (produtos.map<double>((p) => p.localizacao.latitude).reduce(max) +
            produtos.map<double>((p) => p.localizacao.latitude).reduce(min)) /
        2;

    double longitude = (produtos.map<double>((p) => p.localizacao.longitude).reduce(max) +
            produtos.map<double>((p) => p.localizacao.longitude).reduce(min)) /
        2;

    return LatLng(latitude, longitude);
  }

  void _gerarMarkers(List<Produto> produtos) {
    List<Marker> markers = <Marker>[];

    if (widget.produtos.isNotEmpty) {
      isLoading = true;
      for (var i = 0; i < widget.produtos.length; i++) {
        markers.add(Marker(
            point:
                LatLng(widget.produtos[i].localizacao.latitude, widget.produtos[i].localizacao.longitude),
            width: 180,
            height: 180,
            child: GestureDetector(
                child: const Icon(
                  Icons.location_on,
                  size: 50,
                ),
                onTap: () {
                  if (widget.fromDetail) {
                    _showItem(context, i);
                  } else {
                    Navigator.pushNamed(context, Routes.detalheProduto,
                      arguments: <String, Object>{"idProduto": widget.produtos[i].id!});
                  }
                })));
      }

      //LatLng centroide = _calcularCentroideProdutos(produtos);

      setState(() {
        _markers = markers;
        isLoading = false;
        /*Future.delayed(const Duration(seconds: 1), () {
          _mapController.move(centroide, map_lib.defaultZoom);
        });*/
      });
    }
  }

  void _showItem(BuildContext context, int index) {
    Produto produto = widget.produtos[index];
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(produto.nome),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(children: [
            Text(produto.localizacao.descricao ?? ""),
            Text(_dataFormatter.format(produto.dataInsercao!)),
                    Text(_moneyFormatter.format(produto.preco.toDouble()))])
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(builder: (context) {
                      if (widget.fromDetail) return const SizedBox.shrink();

                      return TextButton(
                          child: const Text("Detalhes"),
                          onPressed: () {
                            Navigator.popAndPushNamed(context, Routes.detalheProduto,
                                arguments: <String, Object>{
                                  "idProduto": widget.produtos[index].id!
                                });
                          });
                    }),
                    TextButton(
                        child: const Text("OK"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        })
                  ],
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    
    if (!isLoading) {
      return Scaffold(
          appBar: AppBar(title: const Text("Premium Price")),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: widget.produtos.isNotEmpty ? LatLng(widget.produtos[0].localizacao.latitude,
                      widget.produtos[0].localizacao.longitude) : LatLng(mapProvider.latitude,
                      mapProvider.longitude),
                  initialZoom: map_lib.defaultZoom,
                  cameraConstraint: CameraConstraint.contain(
                    bounds: LatLngBounds(
                      const LatLng(-90, -180),
                      const LatLng(90, 180),
                    ),
                  ),
                ),
                children: [
                  openStreetMapTileLayer,
                  MarkerLayer(
                    markers: _markers,
                  ),
                ],
              )
            ],
          ));
    } else {
      return Scaffold(
          appBar: AppBar(title: const Text("Premium Price")),
          body: Stack(
            children: [_loadingMap()],
          ));
    }
  }

  Shimmer _loadingMap() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey[100]!,
        child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black));
  }
}
