import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:premiumprice/helper/error.dart';
import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/repositories/produto_repository.dart';
import 'package:premiumprice/routes/routes.dart';
import 'package:premiumprice/misc/map/map_lib.dart' as map_lib;

class CadastrarProdutoPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String localizacao;

  const CadastrarProdutoPage({super.key, required this.latitude, required this.longitude, required this.localizacao});

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


  String _localizacaoAtual = '';
  late double _latitude;
  late double _longitude;


  @override
  void initState() {
    super.initState();

    setState(() {
      _latitude = widget.latitude;
      _longitude = widget.longitude;
      _localizacaoAtual = widget.localizacao;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _cadastrarProduto() async {
    try {
      Produto novoProduto = Produto.novo(_nomeProdutoController.text, 
                              _descricaoController.text, 
                              Decimal.parse(_precoController.text), 
                              _latitude, 
                              _longitude);

      novoProduto = await _repository.inserir(novoProduto);

      Navigator.pop(context);
    } catch (exception) {
      showError(context, "Erro inserindo produto", exception.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Premium Price"),
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
            _cadastrarPage()
          ],
        ));
  }

  void _setLocalizacaoAtual(double latitude, double longitude) async {
    String reverseGeocodingString =
        await map_lib.reverseGeocodingString(latitude, longitude);
    setState(() {
      _localizacaoAtual = reverseGeocodingString;
    });
  }

  _navigateDefinirLocalizacaoPage(context) async {
    final LatLong result = await Navigator.pushNamed(
        context, Routes.definirLocalizacao,
        arguments: <String, Object>{
          "latitude": _latitude,
          "longitude": _longitude,
        }) as LatLong;

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!context.mounted) return;

    _latitude = result.latitude;
    _longitude = result.longitude;

    _setLocalizacaoAtual(result.latitude, result.longitude);
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
                    const Text("Produto"),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            border:
                                OutlineInputBorder(), /*labelText: 'Produto:'*/
                          ),
                          controller: _nomeProdutoController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Campo não pode ser vazio';
                            }
                            return null;
                          },
                        )),
                    const Text("Localizacao"),
                        TextButton(
                        onPressed: () {
                          _navigateDefinirLocalizacaoPage(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(child: Text(_localizacaoAtual)),
                            const Icon(Icons.arrow_drop_down)
                          ],
                        )),
                    const Text("Novo Preço"),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border:
                                OutlineInputBorder(), /*labelText: 'Produto:'*/
                          ),
                          controller: _precoController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Campo não pode ser vazio';
                            }
                            return null;
                          },
                        )),
                    const Text("Descrição"),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: TextFormField(
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
                          }
                        )),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _cadastrarProduto();
                        }
                      },
                      child: const Text('Cadastrar'),
                    ),
                  ],
                )),
          ],
        ))
      ],
    );
  }
}
