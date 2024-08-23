import 'package:flutter/material.dart';
import 'package:premiumprice/helper/error.dart';
import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/repositories/produto_repository.dart';

class ConfirmarDigitalizacaoPage extends StatefulWidget {
  static const String routeName = '/digitalizar/confirmar';
  final String urlQr;

  const ConfirmarDigitalizacaoPage({super.key, required this.urlQr});

  @override
  State<StatefulWidget> createState() => _ConfirmarDigitalizacaoPageState();
}

class _ConfirmarDigitalizacaoPageState
    extends State<ConfirmarDigitalizacaoPage> {
  List<Produto> _lista = <Produto>[];

  @override
  void initState() {
    super.initState();

    _refreshList();
  }

  void _refreshList() async {
    List<Produto> tempList = await _buscarProdutosPorUrlQrNFCeFazenda();
    setState(() {
      _lista = tempList;
    });
  }

  Future<List<Produto>> _buscarProdutosPorUrlQrNFCeFazenda() async {
    List<Produto> tempLista = <Produto>[];

    try {
      ProdutoRepository repository = ProdutoRepository();
      tempLista = await repository.buscarPorUrlQrNFCeFazenda(widget.urlQr);
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
        ),
        body: Column(
          children: [
            Expanded(
                child: ListView.builder(
                    itemCount: _lista.length, itemBuilder: _buildItem))
          ],
        ));
  }
}
