import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:premiumprice/helper/error.dart';
import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/repositories/produto_repository.dart';
import 'package:premiumprice/routes/routes.dart';
import 'package:premiumprice/misc/map/map_lib.dart' as map_lib;
import 'package:premiumprice/widgets/produto/detalhe_produto_widget.dart';

class DetalheProdutoPage extends StatefulWidget {
  final int idProduto;

  const DetalheProdutoPage({super.key, required this.idProduto });

  static const String routeName = '/produtos/detalhe';

  @override
  State<StatefulWidget> createState() => _DetalheProdutoPageState();
}

class _DetalheProdutoPageState extends State<DetalheProdutoPage> {
  final ProdutoRepository _repository = ProdutoRepository();
  Future<Produto>? _produto;

  List<Produto> _outrosProdutos = <Produto>[];

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
    try {
      await Future.delayed(const Duration(seconds: 2)); 
      _repository.buscarPorId(idProduto).then((produto) {
        setState(() {
            _produto = Future.value(produto);
        });

        _buscarOutrosProdutos(produto.nome);
      });
    } catch (exception) {
      showError(
          context, "Erro buscando produto", exception.toString());
    }
  }

  void _buscarOutrosProdutos(String nome) async {
    List<Produto> tempList = <Produto>[];

    try {
      tempList = await _repository.buscarPorNome(nome);
      tempList.removeWhere((p) => p.id == widget.idProduto);

      setState(() {
        _outrosProdutos = tempList;
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
        children: [
        Text(p.localizacao ?? ""),
        Text('R\$ ${p.preco}')],),
      onTap: () {
        Navigator.pushNamed(
          context, Routes.detalheProduto,
          arguments: <String, String>{
            "idProduto": _outrosProdutos[index].id.toString()
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
                  children = const <Widget>[
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Awaiting result...'),
                    ),
                  ];
                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: children,
                  ),
                );
            }),
            const Text("Outros estabelecimentos"),
            Expanded(
                child: ListView.builder(
                    itemCount: _outrosProdutos.length, itemBuilder: _buildItem))
            //Text(_produto.nome),
            /*Expanded(
                child: ListView.builder(
                    itemCount: _lista.length, itemBuilder: _buildItem))*/
          ],
        ));
  }
}
