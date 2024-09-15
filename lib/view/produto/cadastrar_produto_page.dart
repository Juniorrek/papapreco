import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:papapreco/exception/unauthorized_exception.dart';
import 'package:papapreco/helper/error.dart';
import 'package:papapreco/misc/auth/auth_provider.dart';
import 'package:papapreco/misc/auth/map_provider.dart';
import 'package:papapreco/model/localizacao.dart';
import 'package:papapreco/model/produto.dart';
import 'package:papapreco/repositories/produto_repository.dart';
import 'package:papapreco/routes/routes.dart';
import 'package:papapreco/misc/map/map_lib.dart' as map_lib;
import 'package:papapreco/view/produto/filtrar_produtos_page.dart';
import 'package:papapreco/widgets/map/definir_localizacao_widget.dart';
import 'package:provider/provider.dart';

class CadastrarProdutoPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String localizacaoString;

  const CadastrarProdutoPage(
      {super.key,
      required this.latitude,
      required this.longitude,
      required this.localizacaoString});

  static const String routeName = '/produtos/cadastrar';

  @override
  State<StatefulWidget> createState() => _CadastrarProdutoPageState();
}

class _CadastrarProdutoPageState extends State<CadastrarProdutoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeProdutoController = TextEditingController();
  final _precoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final ProdutoRepository _repository = ProdutoRepository();

  String _localizacaoString = '';
  late double _latitude;
  late double _longitude;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _latitude = widget.latitude;
      _longitude = widget.longitude;
      _localizacaoString = widget.localizacaoString;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _cadastrarProduto() async {
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
      String novoPrecoTexto = _precoController.text
          .replaceAll('R\$', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim();

      Produto novoProduto = Produto.novo(
          _nomeProdutoController.text,
          _descricaoController.text,
          Decimal.parse(novoPrecoTexto),
          Localizacao.novo(_latitude, _longitude, _localizacaoString),
          DateTime.now(),
          DateTime.now(),
          authProvider.usuario!);

      novoProduto = await _repository.inserir(novoProduto, token);

      if (!mounted) return;
      Navigator.pop(context, novoProduto.nome);
    } on UnauthorizedException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login expirado, entre novamente!'), behavior: SnackBarBehavior.floating),
      );
      Navigator.pushNamed(context, Routes.login, arguments: <String, Object>{"fromUrl": Routes.cadastrarProduto});
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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Papa Preço"),
          //automaticallyImplyLeading: false,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Navigator.pushNamed(context, Routes.digitalizarNota);
          },
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          shape: const CircleBorder(),
          child: const Icon(Icons.camera_alt),
        ),
        body: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(10.0), child: _cadastrarPage())
          ],
        ));
  }

  Row _cadastrarPage() {
    return Row(
      children: [
        Expanded(
            child: Column(
          children: [
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text("Produto",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(), /*labelText: 'Produto:'*/
                      ),
                      controller: _nomeProdutoController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Campo não pode ser vazio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text("Localizacao",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                    Consumer<MapProvider>(
                      builder: (context, mapProvider, child) {
                        return DefinirLocalizacaoWidget(
                            latitude: _latitude,
                            longitude: _longitude,
                            localizacaoString: _localizacaoString,
                            onData: (lat, lng, loc) {
                              setState(() {
                                _latitude = lat;
                                _longitude = lng;
                                _localizacaoString = loc;
                              });
                            });
                      },
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                    const Text("Descrição",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                    TextFormField(
                        decoration: const InputDecoration(
                          border:
                              OutlineInputBorder(), /*labelText: 'Produto:'*/
                        ),
                        controller: _descricaoController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Campo não pode ser vazio';
                          }
                          return null;
                        }),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                          child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  _cadastrarProduto();
                                }
                              },
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                ),
                              )
                            : const Text('Cadastrar'),
                      ))
                    ]),
                  ],
                )),
          ],
        ))
      ],
    );
  }
}
