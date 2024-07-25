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
  final _formKey = GlobalKey<FormState>();
  final _nomeProdutoController = TextEditingController();

  List<Produto> _lista = <Produto>[];

  @override
  void initState() {
    super.initState();

    final Map m = ModalRoute.of(context)!.settings.arguments as Map;
    _nomeProdutoController.text = m["nomeProduto"];
    _refreshList();
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
        //_showItem(context, index);
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
          automaticallyImplyLeading: false,
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
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _refreshList();
                        }
                      },
                      child: const Text('Pesquisar'),
                    )
                  ],
                )),
            Expanded(
                child: ListView.builder(
                    itemCount: _lista.length, itemBuilder: _buildItem))
          ],
        ));
  }
}
