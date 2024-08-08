import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/repositories/produto_repository.dart';

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

  @override
  void initState() {
    super.initState();

    _repository.buscarPorNome(widget.nomeProduto).then((produtos) {
        setState(() {
            _produtos = produtos;

            _markers = _gerarMarkers(_produtos);
        });
    });
  }

  void test() {
    setState(() {
      _markers = _gerarMarkers(_produtos);
    });
  }

  @override
  void dispose() {
    super.dispose();
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
                  markers: _markers,
                ),
              ],
            )
          ],
        ));
  }
}
