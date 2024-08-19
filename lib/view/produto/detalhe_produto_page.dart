import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:premiumprice/helper/error.dart';
import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/repositories/produto_repository.dart';
import 'package:premiumprice/routes/routes.dart';
import 'package:premiumprice/misc/map/map_lib.dart' as map_lib;
import 'package:premiumprice/widgets/produto/detalhe_produto_widget.dart';
import 'package:shimmer/shimmer.dart';

class DetalheProdutoPage extends StatefulWidget {
  final int idProduto;

  const DetalheProdutoPage({super.key, required this.idProduto});

  static const String routeName = '/produtos/detalhe';

  @override
  State<StatefulWidget> createState() => _DetalheProdutoPageState();
}

class _DetalheProdutoPageState extends State<DetalheProdutoPage> {
  final ProdutoRepository _repository = ProdutoRepository();
  Future<Produto>? _produto;

  List<Produto> _outrosProdutos = <Produto>[];

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
    _isLoading = true;
    try {
      //await Future.delayed(const Duration(seconds: 2));
      _repository.buscarPorId(idProduto).then((produto) {
        setState(() {
          _produto = Future.value(produto);
        });

        _buscarOutrosProdutos(produto.nome);
      });
    } catch (exception) {
      showError(context, "Erro buscando produto", exception.toString());
    }
  }

  void _buscarOutrosProdutos(String nome) async {
    List<Produto> tempList = <Produto>[];

    try {
      tempList = await _repository.buscarPorNome(nome);
      tempList.removeWhere((p) => p.id == widget.idProduto);

      setState(() {
        _outrosProdutos = tempList;
        _isLoading = false;
      });
    } catch (exception) {
      showError(
          context, "Erro obtendo lista de produtos", exception.toString());
    }
  }

  ListTile _buildItem(BuildContext context, int index) {
    Produto p = _outrosProdutos[index];

    return ListTile(
      title: Text(p.nome),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(p.localizacao ?? ""), Text('R\$ ${p.preco}')],
      ),
      onTap: () {
        Navigator.pushNamed(context, Routes.detalheProduto,
            arguments: <String, Object>{
              "idProduto": _outrosProdutos[index].id!
            });
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
                    return DetalheProdutoWidget(produto: snapshot.data!);
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
            const Text("Outros estabelecimentos"),
            Expanded(
                child: ListView.builder(
                    itemCount: _outrosProdutos.length, itemBuilder: _buildItem))
          ],
        ));
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
