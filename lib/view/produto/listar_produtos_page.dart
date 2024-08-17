import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:premiumprice/helper/error.dart';
import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/repositories/produto_repository.dart';
import 'package:premiumprice/routes/routes.dart';
import 'package:premiumprice/misc/map/map_lib.dart' as map_lib;

class ListarProdutosPage extends StatefulWidget {
  final String nomeProduto;
  final double latitude;
  final double longitude;

  const ListarProdutosPage({super.key, required this.nomeProduto, required this.latitude, required this.longitude });

  static const String routeName = '/produtos';

  @override
  State<StatefulWidget> createState() => _ListarProdutosPageState();
}

class _ListarProdutosPageState extends State<ListarProdutosPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeProdutoController = TextEditingController();

  List<Produto> _lista = <Produto>[];

  String _localizacaoAtual = '';

  @override
  void initState() {
    super.initState();

    _nomeProdutoController.text = widget.nomeProduto;

    _refreshList();

    _setLocalizacaoAtual(widget.latitude, widget.longitude);
  }

  //NÃO CONSIGO JOGAR NA UTIL PQ PRA CHAMAR NA INITSTATE PRECISA SER ASYNC
  //ENTÃO POR ENQUANTO CODIGO DUPLICADO
  /////////////////////////////////////////////////////////////
  void _setLocalizacaoAtual(double latitude, double longitude) async {
    String reverseGeocodingString = await map_lib.reverseGeocodingString(latitude, longitude);
    setState(() {
      _localizacaoAtual = reverseGeocodingString;
    });
  }

  _navigateDefinirLocalizacaoPage(context) async {
      final LatLong result = await Navigator.pushNamed(context,Routes.definirLocalizacao) as LatLong;

      // When a BuildContext is used from a StatefulWidget, the mounted property
      // must be checked after an asynchronous gap.
      if (!context.mounted) return;

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
      ProdutoRepository repository = ProdutoRepository();
      tempLista = await repository.buscarPorNome(_nomeProdutoController.text);
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
      onTap: () {
        Navigator.pushNamed(
          context, Routes.detalheProduto,
          arguments: <String, Object>{
            "idProduto": _lista[index].id!
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Premium Price"),
          //automaticallyImplyLeading: false,
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
                          controller: _nomeProdutoController,
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
                          Flexible(child: Text('$_localizacaoAtual (5km)')),
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
                                "produtos": _lista
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
                          onPressed: () {},
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
