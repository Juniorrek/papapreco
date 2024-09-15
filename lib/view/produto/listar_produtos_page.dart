import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:papapreco/helper/error.dart';
import 'package:papapreco/misc/auth/auth_provider.dart';
import 'package:papapreco/misc/auth/map_provider.dart';
import 'package:papapreco/model/produto.dart';
import 'package:papapreco/repositories/produto_repository.dart';
import 'package:papapreco/routes/routes.dart';
import 'package:papapreco/widgets/end_drawer.dart';
import 'package:papapreco/widgets/map/definir_localizacao_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ListarProdutosPage extends StatefulWidget {
  final String palavra;

  const ListarProdutosPage({super.key, required this.palavra});

  static const String routeName = '/produtos';

  @override
  State<StatefulWidget> createState() => _ListarProdutosPageState();
}

class _ListarProdutosPageState extends State<ListarProdutosPage> {
  final _formKey = GlobalKey<FormState>();
  final _palavraController = TextEditingController();
  final ProdutoRepository _repository = ProdutoRepository();

  final NumberFormat _moneyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );
  final NumberFormat _priceFormatter = NumberFormat('###0.00', 'pt_BR');


  List<Produto> _lista = <Produto>[];

  bool _isLoading = false;

  Decimal? _precoMin;
  Decimal? _precoMax;

  @override
  void initState() {
    super.initState();

    _palavraController.text = widget.palavra;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MapProvider>(context, listen: false);

      _refreshList(provider.latitude, provider.longitude, provider.distancia);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshList(double latitude, double longitude, double distancia) async {
    setState(() {
      _isLoading = true;
    });

    List<Produto> tempList =
        await _buscarProdutosPorNome(latitude, longitude, distancia);

    setState(() {
      _lista = tempList;
      _isLoading = false;
    });
  }

  Future<List<Produto>> _buscarProdutosPorNome(
      double latitude, double longitude, double distancia) async {
    List<Produto> tempLista = <Produto>[];

    try {
      tempLista = await _repository.ranking(
          _palavraController.text,
          latitude,
          longitude,
          distancia,
          _precoMin ?? Decimal.fromInt(0),
          _precoMax ?? Decimal.fromInt(999999999));
    } catch (exception) {
      if (mounted) {
        showError(
            context, "Erro obtendo lista de produtos", exception.toString());
      }
    }

    return tempLista;
  }

  ListTile _buildItem(BuildContext context, int index) {
    Produto p = _lista[index];
    final mapProvider = Provider.of<MapProvider>(context);

    return ListTile(
      leading: Container(
          width: 80.0,
          height: 50.0,
          alignment: Alignment.center,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'R\$',
                  style: TextStyle(
                    fontSize: 16.0, 
                    fontWeight: FontWeight.normal,
                  ),
                ),
                 Flexible(child:Text(
                  _priceFormatter.format(p.preco.toDouble()),
                  style: const TextStyle(
                    fontSize: 18.0, 
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ],
            ),
          ),
      title: Text(p.nome),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.localizacao.descricao ?? '',
              style: const TextStyle(
                    fontWeight: FontWeight.normal,
                  )),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16.0),
              Text('~${p.distanciaRelativa?.toStringAsFixed(2)}km',
              style: const TextStyle(
                    fontWeight: FontWeight.normal,
                  )),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16.0),
              const SizedBox(width: 4),
              Text(p.dataRelativa ?? '',
              style: const TextStyle(
                    fontWeight: FontWeight.normal,
                  )),
            ],
          ),
        ],
      ),
      onTap: () {
        Navigator.pushNamed(context, Routes.detalheProduto,
            arguments: <String, Object>{"idProduto": p.id!});
      },
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (String value) async {
          final isLoggedIn =
              Provider.of<AuthProvider>(context, listen: false).isLoggedIn;
          if (value == 'edit') {
            if (!isLoggedIn) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Você precisa estar logado.'), behavior: SnackBarBehavior.floating));
            } else {
              await Navigator.pushNamed(context, Routes.sugerirEdicao,
        arguments: <String, Object>{"produto": p});
            }

                  if (!context.mounted) return;
                  _refreshList(mapProvider.latitude, mapProvider.longitude,
                      mapProvider.distancia);
          } else if (value == 'map') {
            Navigator.pushNamed(context, Routes.listarProdutosMapa,
                arguments: <String, Object>{
                  "produtos": List.filled(1, p),
                  "fromDetail": false
                });
          }
        },
        itemBuilder: (BuildContext context) {
          return [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Sugerir novo preço'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'map',
              child: Row(
                children: [
                  Icon(Icons.pin_drop),
                  SizedBox(width: 8),
                  Text('Ver no mapa'),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }

  Future<void> _navigateFiltrarProdutosPage(context) async {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    final Map? result = await Navigator.pushNamed(
        context, Routes.filtrarProdutos,
        arguments: <String, Object?>{
          "palavra": _palavraController.text,
          "distancia": mapProvider.distancia,
          "precoMin": _precoMin,
          "precoMax": _precoMax,
          "latitude": mapProvider.latitude,
          "longitude": mapProvider.longitude,
          "localizacaoString": mapProvider.localizacaoString
        }) as Map<String, Object?>?;

    if (result == null) return;
    if (!context.mounted) return;

    setState(() {
      _palavraController.text = result['palavra'];

      _precoMin = result['precoMin'];
      _precoMax = result['precoMax'];

      mapProvider.setLatitude(result['latitude']);
      mapProvider.setLongitude(result['longitude']);
      mapProvider.setLocalizacaoString(result['localizacaoString']);
    });

    _refreshList(
        mapProvider.latitude, mapProvider.longitude, result['distancia']);
    mapProvider.setDistancia(result['distancia']);
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;

    return Scaffold(
        appBar: AppBar(
        scrolledUnderElevation: 0,
            title: const Text("Papa Preço"),
            leading: BackButton(
                onPressed: () => Navigator.pop(context,
                    <String, Object>{"palavra": _palavraController.text}))),
        endDrawer: const EndDrawer(),
        floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  if (!isLoggedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Você precisa estar logado.'), behavior: SnackBarBehavior.floating));
                  } else {
                    final result = await Navigator.pushNamed(context, Routes.cadastrarProduto,
                        arguments: <String, Object>{
                          "latitude": mapProvider.latitude,
                          "longitude": mapProvider.longitude,
                          "localizacaoString": mapProvider.localizacaoString,
                        });
                    if (!context.mounted) return;

                    if (result != null) {
                      setState(() {
                        _palavraController.text = result as String;
                      });
                    }
                    _refreshList(mapProvider.latitude, mapProvider.longitude,
                        mapProvider.distancia);
                  }
                },
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                shape: const CircleBorder(),
                child: const Icon(Icons.plus_one),
              ),
        body: Column(
          children: [
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Produto:'),
                          controller: _palavraController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Campo não pode ser vazio';
                            }
                            return null;
                          },
                        )),
                    Consumer<MapProvider>(
                      builder: (context, mapProvider, child) {
                        return DefinirLocalizacaoWidget(
                            latitude: mapProvider.latitude,
                            longitude: mapProvider.longitude,
                            localizacaoString: mapProvider.localizacaoString,
                            distancia: mapProvider.distancia,
                            onData: (lat, lng, loc) {
                              mapProvider.setLatitude(lat);
                              mapProvider.setLongitude(lng);
                              mapProvider.setLocalizacaoString(loc);
                            });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.map),
                          iconSize: 40.0,
                          onPressed: () {
                            Navigator.pushNamed(
                                context, Routes.listarProdutosMapa,
                                arguments: <String, Object>{
                                  "produtos": _lista,
                                  "fromDetail": false
                                });
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _refreshList(mapProvider.latitude,
                                  mapProvider.longitude, mapProvider.distancia);
                            }
                          },
                          child: const Text('Pesquisar'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.filter_alt),
                          iconSize: 40.0,
                          onPressed: () =>
                              _navigateFiltrarProdutosPage(context),
                        ),
                      ],
                    ),
                  ],
                )),
            const Divider(),
            Expanded(
                child: _isLoading
                    ? ListView.builder(
                        itemCount: 10,
                        itemBuilder: (context, index) => _shimmerListTile(),
                      )
                    : ListView.builder(
                        itemCount: _lista.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              _buildItem(context, index),
                              if (index < _lista.length - 1) const Divider(),
                            ],
                          );
                        }))
          ],
        ));
  }

  Widget _shimmerListTile() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListTile(
        leading: Container(
          width: 80.0,
          height: 50.0,
          color: Colors.white,
        ),
        title: Container(
          height: 16.0,
          color: Colors.white,
        ),
        subtitle: Container(
          height: 14.0,
          margin: const EdgeInsets.only(top: 4.0),
          color: Colors.white,
        ),
      ),
    );
  }
}
