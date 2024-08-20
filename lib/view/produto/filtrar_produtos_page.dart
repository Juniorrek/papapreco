import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:premiumprice/helper/error.dart';
import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/repositories/produto_repository.dart';
import 'package:premiumprice/routes/routes.dart';
import 'package:premiumprice/misc/map/map_lib.dart' as map_lib;

class FiltrarProdutosPage extends StatefulWidget {
  final String palavra;
  final double latitude;
  final double longitude;
  final String localizacao;
  final double distancia;
  final double precoMin;
  final double precoMax;

  const FiltrarProdutosPage(
      {super.key,
      required this.palavra,
      required this.latitude,
      required this.longitude,
      required this.localizacao,
      required this.distancia,
      required this.precoMin,
      required this.precoMax});

  static const String routeName = '/produtos/filtrar';

  @override
  State<StatefulWidget> createState() => _FiltrarProdutosPageState();
}

class _FiltrarProdutosPageState extends State<FiltrarProdutosPage> {
  final _formKey = GlobalKey<FormState>();
  final _palavraController = TextEditingController();

  String _localizacaoAtual = '';
  late double _latitude;
  late double _longitude;

  late double _currentSliderDistanciaValue;
  final _minPrecoController = TextEditingController();
  final _maxPrecoController = TextEditingController();

  @override
  void initState() {
    super.initState();


    _latitude = widget.latitude;
    _longitude = widget.longitude;
    setState(() {
      _palavraController.text = widget.palavra;

      _localizacaoAtual = widget.localizacao;
      _currentSliderDistanciaValue = widget.distancia;

      /*if (widget.precoMin.toString() != "") {
        _minPrecoController.text = widget.precoMin.toString();
      }
      if (widget.precoMax.toString() != "") {
        _maxPrecoController.text = widget.precoMax.toString();
      }*/
    });
    //_setLocalizacaoAtual(widget.latitude, widget.longitude);
  }

  //NÃO CONSIGO JOGAR NA UTIL PQ PRA CHAMAR NA INITSTATE PRECISA SER ASYNC
  //ENTÃO POR ENQUANTO CODIGO DUPLICADO
  /////////////////////////////////////////////////////////////
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
  /////////////////////////////////////////////////////////////

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _filtrarProdutos() async {
    Navigator.pop(context, <String, Object>{
                    "palavra": _palavraController.text,
                    "latitude": _latitude,
                    "longitude": _longitude,
                    "localizacao": _localizacaoAtual,
                    "distancia": _currentSliderDistanciaValue,
                    "precoMin": _minPrecoController.text != "" ? double.parse(_minPrecoController.text) : widget.precoMin,
                    "precoMax": _maxPrecoController.text != "" ? double.parse(_maxPrecoController.text) : widget.precoMax,
                  });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Premium Price")),
        body: Column(
          children: [
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            const Text("Produto"),
                            Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder()),
                                  controller: _palavraController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Campo não pode ser vazio';
                                    }
                                    return null;
                                  },
                                ))
                          ],
                        )),
                    const SizedBox(height: 5),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            const Text("Localização"),
                            TextButton(
                                onPressed: () {
                                  _navigateDefinirLocalizacaoPage(context);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                        child:
                                            Text('$_localizacaoAtual (${_currentSliderDistanciaValue}km)')),
                                    const Icon(Icons.arrow_drop_down)
                                  ],
                                ))
                          ],
                        )),
                    const SizedBox(height: 5),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text(
                                'Distância ($_currentSliderDistanciaValue km)'),
                            Slider(
                              value: _currentSliderDistanciaValue,
                              max: 50,
                              divisions: 10,
                              label:
                                  '${_currentSliderDistanciaValue.round()} km',
                              onChanged: (double value) {
                                setState(() {
                                  _currentSliderDistanciaValue = value;
                                });
                              },
                            )
                          ],
                        )),
                    const SizedBox(height: 5),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            const Text('Preço'),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                    child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Min:'),
                                            controller: _minPrecoController))),
                                Expanded(
                                    child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Max:'),
                                            controller: _maxPrecoController)))
                              ],
                            )
                          ],
                        )),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _filtrarProdutos();
                        }
                      },
                      child: const Text('Filtrar'),
                    ),
                  ],
                ))
          ],
        ));
  }
}
