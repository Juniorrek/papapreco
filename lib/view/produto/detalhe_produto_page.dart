import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:premiumprice/helper/error.dart';
import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/repositories/produto_repository.dart';
import 'package:premiumprice/routes/routes.dart';
import 'package:shimmer/shimmer.dart';

class DetalheProdutoPage extends StatefulWidget {
  final int idProduto;

  const DetalheProdutoPage({super.key, required this.idProduto});

  static const String routeName = '/produtos/detalhe';

  @override
  State<StatefulWidget> createState() => _DetalheProdutoPageState();
}

class _DetalheProdutoPageState extends State<DetalheProdutoPage> {
  final DateFormat formatter = DateFormat('dd/MM/yyyy – kk:mm');
  final ProdutoRepository _repository = ProdutoRepository();
  Future<Produto>? _produto;

  List<Produto> _historicoProduto = <Produto>[];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _buscarProduto(widget.idProduto);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _buscarProduto(int idProduto) async {
    setState(() {
    _isLoading = true;
    });
    try {
      //await Future.delayed(const Duration(seconds: 1));
      _repository.buscarPorId(idProduto).then((produto) {
        setState(() {
          _produto = Future.value(produto);
        });

        _buscarHistoricoProduto(produto.nome, produto.latitude, produto.longitude);
      });
    } catch (exception) {
      showError(context, "Erro buscando produto", exception.toString());
    }
  }

  void _buscarHistoricoProduto(String nome, double latitude, double longitude) async {
    List<Produto> tempList = <Produto>[];

    try {
      tempList = await _repository.historico(nome, latitude, longitude);
      _produto?.then((p) {
        tempList.removeWhere((pp) => pp.id == p.id);
      });

      setState(() {
        _historicoProduto = tempList;
        _isLoading = false;
      });
    } catch (exception) {
      showError(
          context, "Erro obtendo lista de produtos", exception.toString());
    }
  }

  ListTile _buildItem(BuildContext context, int index) {
    Produto p = _historicoProduto[index];

    return ListTile(
      title: Text(p.nome),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('R\$ ${p.preco}'), Text(formatter.format(p.dataInsercao!)),],
      ),
      onTap: () {
        /*Navigator.pushNamed(context, Routes.detalheProduto,
            arguments: <String, Object>{
              "idProduto": _historicoProduto[index].id!
            });*/
      },
      /*trailing: PopupMenuButton(
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
      ),*/
    );
  }

  
  Future<void> _navigateSugerirEdicaoPage(context, Produto produto) async {
    final result = await Navigator.pushNamed(context, Routes.sugerirEdicao,
                        arguments: <String, Object>{"produto": produto});

    //clicou em retornar
    if (result == null) return;

    Produto p = result as Produto;
    
    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!context.mounted) return;

    _buscarProduto(p.id!);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _loadingDetails();

    return Scaffold(
        appBar: AppBar(
          title: const Text("Premium Price"),
          //automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            FutureBuilder<Produto>(
                future: _produto,
                builder: (context, snapshot) {
                  List<Widget> children;
                  if (snapshot.hasData) {
                    return _detalheProduto(snapshot.data!);
                  } else if (snapshot.hasError) {
                    children = <Widget>[
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text('Error: ${snapshot.error}'),
                      ),
                    ];
                  } else {
                    children = <Widget>[
                      
                    ];
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: children,
                    ),
                  );
                }),
            const SizedBox(height: 10),
            const Text("Histórico"),
            Expanded(
                child: ListView.builder(
                    itemCount: _historicoProduto.length, itemBuilder: _buildItem))
          ],
        ));
  }

  Row _detalheProduto(Produto produto) {
    return Row(
      children: [
        //_buildImage(),
        Expanded(
            child: Column(
          children: [
            Text(produto.nome),
            Text(produto.localizacao ?? ""),
            Text(formatter.format(produto.dataInsercao!)),
            Text('R\$${produto.preco}'),
            Text(produto.descricao ?? ''),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.pin_drop),
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.listarProdutosMapa,
                        arguments: <String, Object>{
                          "produtos": List.filled(1, produto),
                          "fromDetail": true
                          });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateSugerirEdicaoPage(context, produto),)
              ],
            )
          ],
        ))
      ],
    );
  }

  Scaffold _loadingDetails() {
    return Scaffold(
      appBar: AppBar(title: const Text("Premium Price")),
      body: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            Row(
          crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(8.0),
                  height: 100,
                  width: 100,
                  color: Colors.white,
                ),
                Expanded(
                    child: SizedBox(
                  height: 200.0,
                  child: ListView.builder(
                    itemCount: 3, // Adjust the count based on your needs
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Container(
                          height: 20,
                          width: 100,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ))
              ],
            ),
            Expanded(
                child: ListView.builder(
              itemCount: 3, // Adjust the count based on your needs
              itemBuilder: (context, index) {
                return ListTile(
                  title: Container(
                    height: 20,
                    width: 100,
                    color: Colors.white,
                  ),
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
