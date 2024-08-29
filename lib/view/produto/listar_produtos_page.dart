import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:premiumprice/helper/error.dart';
import 'package:premiumprice/misc/auth/auth_provider.dart';
import 'package:premiumprice/misc/auth/map_provider.dart';
import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/repositories/produto_repository.dart';
import 'package:premiumprice/routes/routes.dart';
import 'package:premiumprice/misc/map/map_lib.dart' as map_lib;
import 'package:premiumprice/widgets/end_drawer.dart';
import 'package:premiumprice/widgets/map/definir_localizacao_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ListarProdutosPage extends StatefulWidget {
  final String palavra;

  const ListarProdutosPage(
      {super.key,
      required this.palavra});

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


    //_setLocalizacaoAtual(widget.latitude, widget.longitude);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshList(double latitude, double longitude, double distancia) async {
    setState(() {
      _isLoading = true;
    });

    //await Future.delayed(Duration(seconds: 3));

    List<Produto> tempList = await _buscarProdutosPorNome(latitude, longitude, distancia);

    setState(() {
      _lista = tempList;
      _isLoading = false;
    });
  }

  Future<List<Produto>> _buscarProdutosPorNome(double latitude, double longitude, double distancia) async {
    List<Produto> tempLista = <Produto>[];

    try {
      tempLista = await _repository.ranking(_palavraController.text, latitude,
          longitude, distancia, _precoMin ?? Decimal.fromInt(0), _precoMax ?? Decimal.fromInt(999999999));
    } catch (exception) {
      if(mounted) {
        showError(
          context, "Erro obtendo lista de produtos", exception.toString());
      }
    }

    return tempLista;
  }

  ListTile _buildItem(BuildContext context, int index) {
    Produto p = _lista[index];

    return ListTile(
      leading: Container(
    width: 80.0, // Largura fixa do leading
    height: 50.0, // Altura fixa do leading
    alignment: Alignment.center,
    child:Text(_moneyFormatter.format(p.preco.toDouble()), style: const TextStyle(fontSize: 16.0))),
      title: Text(p.nome),
      subtitle: Text(p.localizacao.descricao ?? ''),//Text(_moneyFormatter.format(p.preco.toDouble())),
      onTap: () async {
        await Navigator.pushNamed(context, Routes.detalheProduto,
            arguments: <String, Object>{"idProduto": _lista[index].id!});

        if (!context.mounted) return;

        //_refreshList();
      },
      trailing: PopupMenuButton<String>(
    icon: const Icon(Icons.more_vert), // Ícone para o botão do menu pop-up
    onSelected: (String value) {
      final isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn;
      if (value == 'edit') {
        if (!isLoggedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Você precisa estar logado.')));
        }
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
          "precoMax": _precoMax
        }) as Map<String, Object?>?;

    //clicou em retornar
    if (result == null) return;

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!context.mounted) return;

    setState(() {
      _palavraController.text = result['palavra'];

      _precoMin = result['precoMin'];
      _precoMax = result['precoMax'];
    });

    _refreshList(mapProvider.latitude, mapProvider.longitude, result['distancia']);
    mapProvider.setDistancia(result['distancia']);
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);

    return Scaffold(
        appBar: AppBar(
            title: const Text("Premium Price"),
            leading: BackButton(
                onPressed: () => Navigator.pop(context, <String, Object>{
                      "palavra": _palavraController.text
                    }))),
      endDrawer:
          context.watch<AuthProvider>().isLoggedIn ? const EndDrawer() : null,
        floatingActionButton: context.watch<AuthProvider>().isLoggedIn ? FloatingActionButton(
          onPressed: () async {
            /*await Navigator.pushNamed(
                context, Routes.cadastrarProduto,
                arguments: <String, Object>{
                  "latitude": _latitude,
                  "longitude": _longitude,
                  "localizacao": _localizacaoAtual,
                });
            if (!context.mounted) return;
            _refreshList();*/
          },
          foregroundColor: Colors.white,
          backgroundColor: Colors.green,
          shape: const CircleBorder(),
          child: const Icon(Icons.plus_one),
        ) : null,
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
                              _refreshList(mapProvider.latitude, mapProvider.longitude, mapProvider.distancia);
                            }
                          },
                          child: const Text('Pesquisar'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.filter_alt),
                          onPressed: () =>
                              _navigateFiltrarProdutosPage(context),
                        ),
                      ],
                    ),
                  ],
                )),
            Expanded(
                child: _isLoading ? ListView.builder(
                  itemCount: 10, // Número de itens de placeholder
                  itemBuilder: (context, index) => _shimmerListTile(),
                )
                  : ListView.builder(itemCount: _lista.length, itemBuilder: _buildItem))
          ],
        ));
  }

  Widget _shimmerListTile() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListTile(
        leading: Container(
          width: 50.0,
          height: 50.0,
          color: Colors.white,
        ),
        title: Container(
          height: 20.0,
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
