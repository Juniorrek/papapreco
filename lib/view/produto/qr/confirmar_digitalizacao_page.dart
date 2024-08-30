import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:papapreco/exception/unauthorized_exception.dart';
import 'package:papapreco/helper/error.dart';
import 'package:papapreco/misc/auth/auth_provider.dart';
import 'package:papapreco/model/produto.dart';
import 'package:papapreco/model/usuario.dart';
import 'package:papapreco/repositories/produto_repository.dart';
import 'package:papapreco/routes/routes.dart';
import 'package:papapreco/view/produto/qr/editar_digitalizacao_page.dart';
import 'package:provider/provider.dart';

class ConfirmarDigitalizacaoPage extends StatefulWidget {
  static const String routeName = '/digitalizar/confirmar';
  final String urlQr;

  const ConfirmarDigitalizacaoPage({super.key, required this.urlQr});

  @override
  State<StatefulWidget> createState() => _ConfirmarDigitalizacaoPageState();
}

class _ConfirmarDigitalizacaoPageState
    extends State<ConfirmarDigitalizacaoPage> {
  final DateFormat _dataFormatter = DateFormat('dd/MM/yyyy – kk:mm');
  List<Produto> _lista = <Produto>[];
  bool _isLoading = true; // Variável para controlar o estado de carregamento
  final ProdutoRepository _repository = ProdutoRepository();

  final NumberFormat _moneyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() async {
    setState(() {
      _isLoading = true; // Começa o carregamento
    });

    List<Produto> tempList = await _buscarProdutosPorUrlQrNFCeFazenda();

    setState(() {
      _lista = tempList;
      _isLoading = false; // Termina o carregamento
    });
  }

  Future<List<Produto>> _buscarProdutosPorUrlQrNFCeFazenda() async {
    List<Produto> tempLista = <Produto>[];

    try {
      Usuario? u = Provider.of<AuthProvider>(context, listen: false).usuario;
      if (u == null) {
        throw Exception('nao logado');
      }

      ProdutoRepository repository = ProdutoRepository();
      tempLista = await repository.buscarPorUrlQrNFCeFazenda(widget.urlQr, u);
    } catch (exception) {
      if (mounted) {
        Navigator.pop(context);
        showError(context, "Erro obtendo lista de produtos", "");
      }
    }

    return tempLista;
  }

  Future<void> _editItem(BuildContext context, int index) async {
    Produto p = _lista[index];
    final result = await Navigator.pushNamed(
      context,
      EditarDigitalizacaoPage.routeName,
      arguments: <String, Object?>{"produto": p},
    );

    if (result == null) return;

    setState(() {
      _lista[index].nome = result.toString();
    });
  }

  ListTile _buildItem(BuildContext context, int index) {
    Produto p = _lista[index];

    return ListTile(
        leading: Container(
            width: 80.0,
            height: 50.0,
            alignment: Alignment.center,
            child: Text(_moneyFormatter.format(p.preco.toDouble()))),
        title: Text(p.nome),
        onTap: () {
          //_showItem(context, index);
        },
        trailing: IconButton(
            onPressed: () {
              _editItem(context, index);
            },
            icon: const Icon(Icons.edit)));
  }

  void _cadastrarProdutos() async {
    setState(() {
      _isLoading = true;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      showError(context, "Erro", "Token de autenticação não encontrado.");
      return;
    }

    try {
      await _repository.inserirLista(_lista, token);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produtos inseridos com sucesso!')),
      );

      Navigator.pushReplacementNamed(context, Routes.home);
    } on UnauthorizedException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login expirado, entre novamente!')),
      );
      Navigator.pushNamed(context, Routes.login);
    } catch (exception) {
      showError(context, "Erro inserindo produto", exception.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Papa Preço"),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _tela(),
    );
  }

  Widget _tela() {
    return Column(children: [
      Text(_lista[0].localizacao.descricao ?? '',
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          )),
      Text(_dataFormatter.format(_lista[0].dataObservacao!),
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.normal,
          )),
      const Divider(),
      Expanded(
          child: ListView.builder(
        itemCount: _lista.length,
        itemBuilder: _buildItem,
      )),
      const Divider(),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            _cadastrarProdutos();
          },
          child: const Text('Inserir'),
        ),
      )
    ]);
  }
}
