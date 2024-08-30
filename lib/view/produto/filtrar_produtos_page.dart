import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:papapreco/misc/auth/map_provider.dart';
import 'package:papapreco/widgets/map/definir_localizacao_widget.dart';
import 'package:provider/provider.dart';

class FiltrarProdutosPage extends StatefulWidget {
  final String palavra;
  final double distancia;
  final Decimal? precoMin;
  final Decimal? precoMax;
  final double latitude;
  final double longitude;
  final String localizacaoString;

  const FiltrarProdutosPage(
      {super.key,
      required this.palavra,
      required this.distancia,
      required this.precoMin,
      required this.precoMax, required this.latitude, required this.longitude, required this.localizacaoString});

  static const String routeName = '/produtos/filtrar';

  @override
  State<StatefulWidget> createState() => _FiltrarProdutosPageState();
}

class _FiltrarProdutosPageState extends State<FiltrarProdutosPage> {
  final _formKey = GlobalKey<FormState>();
  final _palavraController = TextEditingController();

  late double _currentSliderDistanciaValue;
  final _minPrecoController = TextEditingController();
  final _maxPrecoController = TextEditingController();
  final MoneyInputFormatter _moneyInputFormatter = MoneyInputFormatter();

  late double _latitude;
  late double _longitude;
  late String _localizacaoString;

  @override
  void initState() {
    super.initState();

    setState(() {
      _palavraController.text = widget.palavra;
      _currentSliderDistanciaValue = widget.distancia;
      _latitude = widget.latitude;
      _longitude = widget.longitude;
      _localizacaoString = widget.localizacaoString;

      if (widget.precoMin != null) {
        _minPrecoController.text =
            _moneyInputFormatter.formatDecimal(widget.precoMin!);
      }
      if (widget.precoMax != null) {
        _maxPrecoController.text =
            _moneyInputFormatter.formatDecimal(widget.precoMax!);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _filtrarProdutos() async {
    Navigator.pop(context, <String, Object?>{
      "palavra": _palavraController.text,
      "distancia": _currentSliderDistanciaValue,
      "precoMin": _textoToPreco(_minPrecoController.text),
      "precoMax": _textoToPreco(_maxPrecoController.text),
      "latitude": _latitude,
      "longitude": _longitude,
      "localizacaoString": _localizacaoString,
    });
  }

  Decimal? _textoToPreco(String? texto) {
    if (texto == null || texto == '') return null;

    // Remove prefixo e espaços extras
    String cleanPrice = texto.replaceAll(RegExp(r'[^\d,]'), '');

    // Substitui a vírgula por ponto para conversão
    String priceWithDot = cleanPrice.replaceAll(',', '.');

    // Converte a string para um valor decimal
    double price = double.parse(priceWithDot);

    return Decimal.parse(price.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text("Papa Preço")),
        body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                const Text("Produto:",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold)),
                                TextFormField(
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder()),
                                  controller: _palavraController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Campo não pode ser vazio';
                                    }
                                    return null;
                                  },
                                )
                              ],
                            )),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            const Text("Localização:",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold)),
                            Consumer<MapProvider>(
                              builder: (context, mapProvider, child) {
                                return DefinirLocalizacaoWidget(
                                    latitude: _latitude,
                                    longitude: _longitude,
                                    localizacaoString:
                                        _localizacaoString,
                                    distancia: _currentSliderDistanciaValue,
                                    onData: (lat, lng, loc) {
                                      setState(() {
                                        _latitude = lat;
                                        _longitude = lng;
                                        _localizacaoString = loc;
                                      });
                                    });
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            Text(
                                'Distância (${_currentSliderDistanciaValue.round()} km):',
                                style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold)),
                            SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor:
                                    Colors.amber, // Cor da faixa ativa
                                inactiveTrackColor: Colors.amber
                                    .withOpacity(0.5), // Cor da faixa inativa
                                thumbColor:
                                    Colors.amber, // Cor do botão deslizante
                                overlayColor: Colors.amber.withOpacity(
                                    0.2), // Cor do overlay (efeito de toque)
                                valueIndicatorColor:
                                    Colors.amber, // Cor do indicador de valor
                                valueIndicatorTextStyle: const TextStyle(
                                    color: Colors
                                        .black), // Cor do texto do indicador de valor
                              ),
                              child: Slider(
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
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            const Text('Preço:',
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold)),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                    child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: TextFormField(
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                                decimal: true),
                                            inputFormatters: [
                                              MoneyInputFormatter(),
                                            ],
                                            decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Min:'),
                                            controller: _minPrecoController))),
                                Expanded(
                                    child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: TextFormField(
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                                decimal: true),
                                            inputFormatters: [
                                              MoneyInputFormatter(),
                                            ],
                                            decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Max:'),
                                            controller: _maxPrecoController)))
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(children: [
                          Expanded(
                              child: OutlinedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _filtrarProdutos();
                              }
                            },
                            child: const Text('Filtrar'),
                          ))
                        ]),
                      ],
                    ))
              ],
            )));
  }
}

class MoneyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '',
    decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove caracteres não numéricos e converte para número
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Converte o texto para número e formata
    final number = double.parse(text) / 100;
    final formattedText = _formatter.format(number);

    // Adiciona 'R$' ao início se houver valor
    final finalText = number > 0 ? 'R\$ $formattedText' : '';

    // Mantém o cursor na posição correta
    return newValue.copyWith(
      text: finalText,
      selection: TextSelection.collapsed(offset: finalText.length),
    );
  }

  // Método auxiliar para formatar um valor Decimal diretamente
  String formatDecimal(Decimal decimal) {
    final number = decimal.toDouble();
    return number > 0 ? 'R\$ ${_formatter.format(number)}' : '';
  }
}
