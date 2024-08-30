import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:papapreco/helper/error.dart';
import 'package:papapreco/helper/success.dart';
import 'package:papapreco/misc/auth/auth_provider.dart';
import 'package:papapreco/model/produto.dart';
import 'package:papapreco/repositories/produto_repository.dart';
import 'package:papapreco/repositories/voto_usuario_produto_repository.dart';
import 'package:papapreco/routes/routes.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class DetalheProdutoPage extends StatefulWidget {
  final int idProduto;

  const DetalheProdutoPage({super.key, required this.idProduto});

  static const String routeName = '/produtos/detalhe';

  @override
  State<StatefulWidget> createState() => _DetalheProdutoPageState();
}

class _DetalheProdutoPageState extends State<DetalheProdutoPage> {
  final DateFormat _dataFormatter = DateFormat('dd/MM/yyyy – kk:mm');
  final ProdutoRepository _repository = ProdutoRepository();
  final VotoUsuarioProdutoRepository _votoRepository =
      VotoUsuarioProdutoRepository();
  Future<Produto>? _produto;

  List<Produto> _historicoProduto = <Produto>[];

  bool _isLoading = false;

  final int IDUSUARIOGAMBI = 7;

   final NumberFormat _moneyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

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

        _buscarHistoricoProduto(
            produto.nome, produto.localizacao.latitude, produto.localizacao.longitude);
      });
    } catch (exception) {
      showError(context, "Erro buscando produto", exception.toString());
    }
  }

  void _buscarHistoricoProduto(
      String nome, double latitude, double longitude) async {
    List<Produto> tempList = <Produto>[];

    try {
      tempList = await _repository.historico(nome, latitude, longitude);
      await _produto?.then((p) {
        tempList.removeWhere((pp) => pp.id == p.id);
      });

      setState(() {
        _historicoProduto = tempList;
        _isLoading = false;
      });
    } catch (exception) {
      if (mounted) {
        showError(
          context, "Erro obtendo lista de produtos", exception.toString());
      }
    }
  }

  Future<void> _votar(Produto produto, int usuarioId, bool voto) async {
    try {
      if (!produto.usuarioJaVotou(IDUSUARIOGAMBI)) {
        await _votoRepository.votar(produto.id!, usuarioId, voto);

        if (mounted) {
          Navigator.of(context).pop();

          showSuccess(context, "Voto realizado com sucesso");
        }
      } else {
        await _votoRepository.mudarVoto(produto.id!, usuarioId, voto);

        if (mounted) {
          Navigator.of(context).pop();

          showSuccess(context, "Voto alterado com sucesso");
        }
      }

      _buscarProduto(widget.idProduto);
    } catch (exception) {
      if (mounted) {
        Navigator.of(context).pop();
        showError(context, "Já votou nesse produto", exception.toString());
      }
    }
  }

  ListTile _buildItem(BuildContext context, int index) {
    Produto p = _historicoProduto[index];

    return ListTile(
      title: Text(p.nome),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_moneyFormatter.format(p.preco.toDouble())),
          Text(_dataFormatter.format(p.dataInsercao!)),
        ],
      ),
      onTap: () {
        _showAvaliar(context, p);
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
          title: const Text("Papa Preço"),
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
                    children = <Widget>[];
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: children,
                    ),
                  );
                }),
            const SizedBox(height: 10),
            _historicoProduto.isNotEmpty
                ? const Text("Histórico")
                : const SizedBox.shrink(),
            Expanded(
                child: ListView.builder(
                    itemCount: _historicoProduto.length,
                    itemBuilder: _buildItem))
          ],
        ));
  }

  Future<void> _showAvaliar(BuildContext context, Produto produto) async {
    Produto? selecionado = await _produto;
    final isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn;

    if (!mounted) return;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(produto.nome),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(selecionado?.localizacao.descricao ?? ''),
                  Text(_dataFormatter.format(produto.dataInsercao!)),
                  Text(_moneyFormatter.format(produto.preco.toDouble())),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            if (!isLoggedIn) {
                              ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Você precisa estar logado.')));
                            } else {
                              if (!produto.usuarioJaVotouVoto(IDUSUARIOGAMBI, false)) {
                                _votar(produto, IDUSUARIOGAMBI, false);
                              }
                            }
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.thumb_down, color: Colors.red),
                              SizedBox(
                                  width:
                                      4), // Espaçamento entre o ícone e o texto
                              Text('Dislike'),
                            ],
                          ),
                        ),
                        Text(produto.qntVotos(false).toString())
                      ],
                    ),
                    Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            if (!isLoggedIn) {
                              ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Você precisa estar logado.')));
                            } else {
                              if (!produto.usuarioJaVotouVoto(IDUSUARIOGAMBI, true)) {
                                _votar(produto, IDUSUARIOGAMBI, true);
                              }
                            }
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.thumb_up, color: Colors.green),
                              SizedBox(
                                  width:
                                      4), // Espaçamento entre o ícone e o texto
                              Text('Like'),
                            ],
                          ),
                        ),
                        Text(produto.qntVotos(true).toString())
                      ],
                    )
                  ],
                )
              ]);
        });
  }

  Row _detalheProduto(Produto produto) {
    final isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn;
      
    return Row(
      children: [
        //_buildImage(),
        Expanded(
            child: Column(
          children: [
            Text(produto.nome),
            Text(produto.localizacao.descricao ?? ""),
            Text(_dataFormatter.format(produto.dataInsercao!)),
            TextButton(
                onPressed: () {
                  _showAvaliar(context, produto);
                },
                child: Text(_moneyFormatter.format(produto.preco.toDouble()))),
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
                  onPressed: () { 
                    if (!isLoggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Você precisa estar logado.')));
                    } else {
                    _navigateSugerirEdicaoPage(context, produto);}},
                )
              ],
            )
          ],
        ))
      ],
    );
  }

  Scaffold _loadingDetails() {
    return Scaffold(
      appBar: AppBar(title: const Text("Papa Preço")),
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
