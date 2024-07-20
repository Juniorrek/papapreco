import 'package:flutter/material.dart';
import 'package:premiumprice/helper/error.dart';
import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/repositories/produto_repository.dart';

class ListarProdutosPage extends StatefulWidget {
  const ListarProdutosPage({super.key});

  static const String routeName = '/produtos';

  @override
  State<StatefulWidget> createState() => _ListarProdutosPageState();
}

class _ListarProdutosPageState extends State<ListarProdutosPage> {
  String _nomeProduto = "";
  List<Produto> _lista = <Produto>[];

  @override
  void initState() {
    super.initState();
    //_refreshList();
  }

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
      tempLista = await repository.buscarPorNome(_nomeProduto);
    } catch (exception) {
      showError(context, "Erro obtendo lista de produtos", exception.toString());
    }

    return tempLista;
  }

  @override
  Widget build(BuildContext context) {
    final Map m = ModalRoute.of(context)!.settings.arguments as Map;
    _nomeProduto = m["nomeProduto"];

    return Scaffold(
     body: Center(child: Text(_nomeProduto),),
    );
  }

}