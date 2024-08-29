import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:premiumprice/misc/auth/map_provider.dart';
import 'package:premiumprice/widgets/map/definir_localizacao_widget.dart';
import 'package:provider/provider.dart';

class FiltrarProdutosPage extends StatefulWidget {
  final String palavra;
  final double distancia;
  final Decimal? precoMin;
  final Decimal? precoMax;

  const FiltrarProdutosPage(
      {super.key,
      required this.palavra,
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

  late double _currentSliderDistanciaValue;
  final _minPrecoController = TextEditingController();
  final _maxPrecoController = TextEditingController();
  final MoneyInputFormatter _moneyInputFormatter = MoneyInputFormatter();

  @override
  void initState() {
    super.initState();

    setState(() {
      _palavraController.text = widget.palavra;
      _currentSliderDistanciaValue = widget.distancia;

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
                            Text("Produto:",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        )),
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
                            Text("Localização:",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        )),
                            Consumer<MapProvider>(
                        builder: (context, mapProvider, child) {
                          return DefinirLocalizacaoWidget(
                              latitude: mapProvider.latitude,
                              longitude: mapProvider.longitude,
                              localizacaoString: mapProvider.localizacaoString,
                              distancia: mapProvider.distancia,
                              onData: (lat, lng, loc) {
                                mapProvider.setLatitude(lat);
                                mapProvider.setLongitude(lng);
                                mapProvider.setLocalizacaoString(loc);
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
                            Text(
                                'Distância (${_currentSliderDistanciaValue.round()} km):',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        )),
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
                            Text('Preço:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        )),
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
