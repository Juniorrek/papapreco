import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:premiumprice/helper/error.dart';
import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/repositories/produto_repository.dart';
import 'package:premiumprice/routes/routes.dart';
import 'package:premiumprice/misc/map/map_lib.dart' as map_lib;

class ListarProdutosPage extends StatefulWidget {
  final String palavra;
  final double latitude;
  final double longitude;
  final String localizacao;
  final double distancia;

  const ListarProdutosPage(
      {super.key,
      required this.palavra,
      required this.latitude,
      required this.longitude,
      required this.localizacao,
      required this.distancia});

  static const String routeName = '/produtos';

  @override
  State<StatefulWidget> createState() => _ListarProdutosPageState();
}

class _ListarProdutosPageState extends State<ListarProdutosPage> {
  final _formKey = GlobalKey<FormState>();
  final _palavraController = TextEditingController();
  ProdutoRepository _repository = ProdutoRepository();

  List<Produto> _lista = <Produto>[];

  String _localizacaoAtual = '';
  late double _latitude;
  late double _longitude;

  late double _distancia;
  double _precoMin = 0.0;
  double _precoMax = 999999.0;

  @override
  void initState() {
    super.initState();

    _palavraController.text = widget.palavra;

    _latitude = widget.latitude;
    _longitude = widget.longitude;

    _distancia = widget.distancia;

    _refreshList();

    setState(() {
      _localizacaoAtual = widget.localizacao;
    });
    //_setLocalizacaoAtual(widget.latitude, widget.longitude);
  }

  //NÃO CONSIGO JOGAR NA UTIL PQ PRA CHAMAR NA INITSTATE PRECISA SER ASYNC
  //ENTÃO POR ENQUANTO CODIGO DUPLICADO
  /////////////////////////////////////////////////////////////
  void _setLocalizacaoAtual(double latitude, double longitude) async {
    String reverseGeocodingString =
        await map_lib.reverseGeocodingString(latitude, longitude);
    setState(() {
      _localizacaoAtual = reverseGeocodingString;
    });
  }

  _navigateDefinirLocalizacaoPage(context) async {
    final LatLong result = await Navigator.pushNamed(
        context, Routes.definirLocalizacao,
        arguments: <String, Object>{
          "latitude": _latitude,
          "longitude": _longitude,
        }) as LatLong;

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!context.mounted) return;

    _latitude = result.latitude;
    _longitude = result.longitude;

    _setLocalizacaoAtual(result.latitude, result.longitude);
  }
  /////////////////////////////////////////////////////////////

  @override
  void dispose() {
    super.dispose();
  }

  void _refreshList() async {
    List<Produto> tempList = await _buscarProdutosPorNome();
    setState(() {
      _lista = tempList;
    });
  }

  Future<List<Produto>> _buscarProdutosPorNome() async {
    List<Produto> tempLista = <Produto>[];

    try {
      tempLista = await _repository.ranking(_palavraController.text, _latitude,
          _longitude, _distancia, _precoMin, _precoMax);
    } catch (exception) {
      showError(
          context, "Erro obtendo lista de produtos", exception.toString());
    }

    return tempLista;
  }

  ListTile _buildItem(BuildContext context, int index) {
    Produto p = _lista[index];

    return ListTile(
      leading: const Icon(Icons.image),
      title: Text(p.nome),
      subtitle: Text('R\$ ${p.preco}'),
      onTap: () async {
        final result = await Navigator.pushNamed(context, Routes.detalheProduto,
            arguments: <String, Object>{"idProduto": _lista[index].id!});

        if (!context.mounted) return;

        _refreshList();
      },
      trailing: PopupMenuButton(
        itemBuilder: (context) {
          return [
            const PopupMenuItem(value: 'edit', child: Text('Editar')),
            const PopupMenuItem(value: 'delete', child: Text('Remover'))
          ];
        },
        onSelected: (String value) {
          if (value == 'edit') {
            //_editItem(context, index);
          } else {
            //_removeItem(context, index);
          }
        },
      ),
    );
  }

  Future<void> _navigateFiltrarProdutosPage(context) async {
    final Map? result = await Navigator.pushNamed(
        context, Routes.filtrarProdutos,
        arguments: <String, Object>{
          "palavra": _palavraController.text,
          "latitude": _latitude,
          "longitude": _longitude,
          "localizacao": _localizacaoAtual,
          "distancia": _distancia,
          "precoMin": _precoMin,
          "precoMax": _precoMax
        }) as Map<String, Object>?;

    //clicou em retornar
    if (result == null) return;

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!context.mounted) return;

    List<Produto> tempLista = <Produto>[];

    try {
      tempLista = await _repository.ranking(
          result!['palavra'],
          result['latitude'],
          result['longitude'],
          result['distancia'],
          result['precoMin'],
          result['precoMax']);
    } catch (exception) {
      showError(
          context, "Erro filtrando lista de produtos", exception.toString());
    }
    setState(() {
      _palavraController.text = result!['palavra'];
      _latitude = result['latitude'];
      _longitude = result['longitude'];
      _localizacaoAtual = result['localizacao'];

      _distancia = result['distancia'];
      _precoMin = result['precoMin'];
      _precoMax = result['precoMax'];

      _lista = tempLista;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Premium Price"),
            leading: BackButton(
                onPressed: () => Navigator.pop(context, <String, Object>{
                      "palavra": _palavraController.text,
                      "latitude": _latitude,
                      "longitude": _longitude,
                      "localizacao": _localizacaoAtual,
                      "distancia": _distancia
                    }))),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.pushNamed(
                context, Routes.cadastrarProduto,
                arguments: <String, Object>{
                  "latitude": _latitude,
                  "longitude": _longitude,
                  "localizacao": _localizacaoAtual,
                });
            if (!context.mounted) return;
            _refreshList();
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
                    TextButton(
                        onPressed: () {
                          _navigateDefinirLocalizacaoPage(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                                child: Text(
                                    '$_localizacaoAtual (${_distancia}km)')),
                            const Icon(Icons.arrow_drop_down)
                          ],
                        )),
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
                              _refreshList();
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
                child: ListView.builder(
                    itemCount: _lista.length, itemBuilder: _buildItem))
          ],
        ));
  }
}
