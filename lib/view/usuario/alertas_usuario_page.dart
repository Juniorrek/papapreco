import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:papapreco/exception/unauthorized_exception.dart';
import 'package:papapreco/helper/error.dart';
import 'package:papapreco/misc/auth/auth_provider.dart';
import 'package:papapreco/misc/auth/map_provider.dart';
import 'package:papapreco/model/alerta_usuario.dart';
import 'package:papapreco/model/localizacao.dart';
import 'package:papapreco/model/usuario.dart';
import 'package:papapreco/repositories/alerta_usuario_repository.dart';
import 'package:papapreco/rest/usuario_rest.dart';
import 'package:papapreco/routes/routes.dart';
import 'package:papapreco/view/produto/filtrar_produtos_page.dart';
import 'package:papapreco/widgets/end_drawer.dart';
import 'package:papapreco/widgets/map/definir_localizacao_widget.dart';
import 'package:provider/provider.dart';

class AlertasUsuarioPage extends StatefulWidget {
  const AlertasUsuarioPage({super.key});

  static const String routeName = '/usuario/alertas';

  @override
  State<AlertasUsuarioPage> createState() => _AlertasUsuarioPageState();
}

class _AlertasUsuarioPageState extends State<AlertasUsuarioPage> {
  List<AlertaUsuario> _alertasUsuario = [];
  final TextEditingController _produtoController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  AlertaUsuario? _alertaSelecionado;
  final AlertaUsuarioRepository _repository = AlertaUsuarioRepository();

  final UsuarioRest _usuarioRest = UsuarioRest();

  bool _isLoading = false;

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

  Future<void> _refreshList() async {
    List<AlertaUsuario> tempList = await _obterTodos();
    setState(() {
      _alertasUsuario = tempList;
    });
  }

  Future<List<AlertaUsuario>> _obterTodos() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    List<AlertaUsuario> tempLista = <AlertaUsuario>[];

    if (token == null) {
      showError(context, "Erro", "Token de autenticação não encontrado.");
      return tempLista;
    }
    final usuario = authProvider.usuario;

    setState(() {
      _isLoading = true;
    });

    try {
      AlertaUsuarioRepository repository = AlertaUsuarioRepository();
      tempLista = await repository.buscarPorUsuario(usuario!.id!, token);
    } on UnauthorizedException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Login expirado, entre novamente!'),
            behavior: SnackBarBehavior.floating),
      );
      Navigator.pushNamed(context, Routes.login, arguments: <String, Object>{"fromUrl": Routes.alertasUsuario});
    } catch (exception) {
      showError(
          context, "Erro obtendo lista de notificações", exception.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    return tempLista;
  }

  void _inserirEditarNotificacao() async {
    setState(() {
      _isLoading = true;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      showError(context, "Erro", "Token de autenticação não encontrado.");
      return;
    }

    final produto = _produtoController.text;

    String precoTexto = _precoController.text
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    final preco = Decimal.parse(precoTexto);

    try {
      if (produto.isNotEmpty && preco != null) {
        if (_alertaSelecionado == null) {
          await _repository.inserir(
              AlertaUsuario.novo(produto, preco, authProvider.usuario!), token);
        } else {
          await _repository.alterar(
              AlertaUsuario(_alertaSelecionado?.id, produto, preco,
                  authProvider.usuario!),
              token);
        }
        await _refreshList();

        _produtoController.clear();
        _precoController.clear();
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Por favor, preencha todos os campos corretamente.')),
        );
      }
    } on UnauthorizedException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Login expirado, entre novamente!'),
            behavior: SnackBarBehavior.floating),
      );
      Navigator.pushNamed(context, Routes.login, arguments: <String, Object>{"fromUrl": Routes.alertasUsuario});
    } catch (exception) {
      showError(context, "Erro inserindo produto", exception.toString());
    }/* finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }*/
  }

  void _removerAlertaUsuario(AlertaUsuario a) async {
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
      await _repository.remover(a.id!, token);

      await _refreshList();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sucesso!')),
      );
    } on UnauthorizedException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Login expirado, entre novamente!'),
            behavior: SnackBarBehavior.floating),
      );
      Navigator.pushNamed(context, Routes.login, arguments: <String, Object>{"fromUrl": Routes.alertasUsuario});
    } catch (exception) {
      showError(context, "Erro excluindo alerta", exception.toString());
    }/* finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }*/
  }

  void _atualizarLocalizacao(double lat, double lng, String loc) async {
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
      Usuario usuario = authProvider.usuario!;
      usuario.localizacao = Localizacao.novo(lat, lng, loc);

      usuario = await _usuarioRest.alterarLocalizacaoAlertas(usuario, token);

      await authProvider.setUsuario(usuario);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sucesso!')),
      );
    } on UnauthorizedException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Login expirado, entre novamente!'),
            behavior: SnackBarBehavior.floating),
      );
      Navigator.pushNamed(context, Routes.login, arguments: <String, Object>{"fromUrl": Routes.alertasUsuario});
    } catch (exception) {
      showError(context, "Erro atualizando localizacao", exception.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showForm([AlertaUsuario? alerta]) {
    if (alerta != null) {
      _produtoController.text = alerta.produto;
      _precoController.text = _moneyFormatter.format(alerta.preco.toDouble());
      _alertaSelecionado = alerta;
    } else {
      _produtoController.clear();
      _precoController.clear();
      _alertaSelecionado = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 16.0),
                  Text(
                      _alertaSelecionado == null
                          ? 'Adicionar Notificação'
                          : 'Editar Notificação',
                      style: const TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16.0),
                  const Text("Produto",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold)),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(), /*labelText: 'Produto:'*/
                    ),
                    controller: _produtoController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Campo não pode ser vazio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  const Text("Preço",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold)),
                  TextFormField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      MoneyInputFormatter(),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(), /*labelText: 'Produto:'*/
                    ),
                    controller: _precoController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Campo não pode ser vazio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      if (!_isLoading) _inserirEditarNotificacao();
                    },
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Salvar'),
                  ),
                  const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ],
              )),
        );
      },
    );
  }

  ListTile _buildItem(BuildContext context, int index) {
    AlertaUsuario n = _alertasUsuario[index];

    return ListTile(
      leading: const Icon(Icons.notifications_active_outlined),
      title:
          Text('${n.produto} - ${_moneyFormatter.format(n.preco.toDouble())}'),
      //subtitle: Text(b.cpf),
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
            _showForm(n);
          } else {
            _removeItem(context, index);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;

    return Scaffold(
        appBar: AppBar(title: const Text('Gerenciar Notificações')),
        endDrawer: const EndDrawer(),
        floatingActionButton: _alertasUsuario.length < 5 && !_isLoading
            ? FloatingActionButton(
                onPressed: () async {
                  _showForm();
                },
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                shape: const CircleBorder(),
                child: const Icon(Icons.plus_one),
              )
            : null,
        body: _isLoading
                        ? const Center(child:CircularProgressIndicator())
                        : Column(children: [
          const Text("Localizacao Alertas",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          Consumer<MapProvider>(
            builder: (context, mapProvider, child) {
              return DefinirLocalizacaoWidget(
                  latitude: usuario?.localizacao?.latitude,
                  longitude: usuario?.localizacao?.longitude,
                  localizacaoString: usuario?.localizacao?.descricao,
                  //distancia: 10.0,
                  onData: (lat, lng, loc) {
                      _atualizarLocalizacao(lat, lng, loc);
                  });
            },
          ),
          if (_alertasUsuario.isNotEmpty) ...[
            Expanded(
                child: ListView.builder(
              itemCount: _alertasUsuario.length,
              itemBuilder: _buildItem,
            )),
          ],
          if (_alertasUsuario.isEmpty) ...[
            const Divider(thickness: 2),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Nenhum alerta configurado!",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          if (_alertasUsuario.length >= 5) ...[
            const Divider(thickness: 2),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Máximo de 5 alertas!",
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            ),
          ]
        ]));
  }

  void _removeItem(BuildContext context, int index) {
    AlertaUsuario a = _alertasUsuario[index];
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text("Remover Alerta"),
              content: Text("Gostaria realmente de remover ${a.produto}?"),
              actions: [
                TextButton(
                  child: const Text("Não"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text("Sim"),
                  onPressed: () {
                    _removerAlertaUsuario(a);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  /*void _removerAlertaUsuario(AlertaUsuario cliente) async {
    try {
      PedidoRepository pedidoRepository = PedidoRepository();
      List<Pedido> pedidos = await pedidoRepository.listarPorCpf(cliente.cpf);

      if (pedidos.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Não é possível excluir esse cliente pois ele tem pedidos.')));
      } else {
        AlertaUsuarioRepository repository = AlertaUsuarioRepository();
        await repository.remover(cliente.id!).then((value) {
          _refreshList();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('AlertaUsuario ${cliente.id} removido com sucesso.')));
        });
      }
    } catch (exception) {
      showError(context, "Erro removendo cliente", exception.toString());
    }
  }*/
}
