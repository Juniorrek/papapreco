import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:premiumprice/view/definir_localizacao_page.dart';
import 'package:premiumprice/view/produto/cadastrar_produto_page.dart';
import 'package:premiumprice/view/produto/confirmar_digitalizacao_page.dart';
import 'package:premiumprice/view/produto/detalhe_produto_page.dart';
import 'package:premiumprice/view/produto/digitalizar_nota_page.dart';
import 'package:premiumprice/view/produto/filtrar_produtos_page.dart';
import 'package:premiumprice/view/produto/listar_produtos_mapa_page.dart';
import 'package:premiumprice/view/produto/listar_produtos_page.dart';
import 'package:premiumprice/misc/map/map_lib.dart' as map_lib;
import 'package:premiumprice/view/produto/sugerir_edicao_page.dart';
import 'package:shimmer/shimmer.dart';

import 'routes/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Premium Price',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Premium Price'),
      routes: {
        Routes.home: (context) => const MyHomePage(title: 'Premium Price'),
        //Routes.listarProdutos: (context) => const ListarProdutosPage(),
        //paginas com parametro nao precisam ser declaradas aqui ja que estao embaixos
        //Routes.listarProdutosMapa: (context) => const ListarProdutosMapaPage(),
        //Routes.definirLocalizacao: (context) => const DefinirLocalizacaoPage(),
        Routes.digitalizarNota: (context) => const DigitalizarNotaPage()
      },
      onGenerateRoute: (settings) {
        final Map args = settings.arguments as Map<String, Object>;

        Map routes = <String, WidgetBuilder>{
          Routes.definirLocalizacao: (ctx) => DefinirLocalizacaoPage(
              latitude: args["latitude"], longitude: args["longitude"]),
          Routes.listarProdutos: (ctx) => ListarProdutosPage(
              palavra: args["palavra"],
              latitude: args["latitude"],
              longitude: args["longitude"],
              localizacao: args["localizacao"],
              distancia: args["distancia"]),
          Routes.cadastrarProduto: (ctx) => CadastrarProdutoPage(
              latitude: args["latitude"],
              longitude: args["longitude"],
              localizacao: args["localizacao"]),
          Routes.detalheProduto: (ctx) =>
              DetalheProdutoPage(idProduto: args["idProduto"]),
          Routes.sugerirEdicao: (ctx) =>
              SugerirEdicaoPage(produto: args["produto"]),
          Routes.listarProdutosMapa: (ctx) => ListarProdutosMapaPage(
                produtos: args["produtos"],
                fromDetail: args["fromDetail"],
              ),
          Routes.filtrarProdutos: (ctx) => FiltrarProdutosPage(
              palavra: args["palavra"],
              latitude: args["latitude"],
              longitude: args["longitude"],
              localizacao: args["localizacao"],
              distancia: args["distancia"],
              precoMin: args["precoMin"],
              precoMax: args["precoMax"]),
          Routes.confirmarDigitalizacao: (ctx) =>
              ConfirmarDigitalizacaoPage(urlQr: args["urlQr"]),
        };

        WidgetBuilder builder = routes[settings.name];
        return MaterialPageRoute(builder: (ctx) => builder(ctx));
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  static const String routeName = '/home';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();

  final _palavraController = TextEditingController();

  String _localizacaoAtual = '';
  double? latitude = null;
  double? longitude = null;
  double _distancia = 5.0;

  @override
  void initState() {
    super.initState();

    _setCurrentPosition();
  }

  //NÃO CONSIGO JOGAR NA UTIL PQ PRA CHAMAR NA INITSTATE PRECISA SER ASYNC
  //ENTÃO POR ENQUANTO CODIGO DUPLICADO
  /////////////////////////////////////////////////////////////
  Future<void> _setCurrentPosition() async {
    Position? p = await map_lib.currentLocation();

    if (p != null) {
      _setLocalizacaoAtualString(p.latitude, p.longitude);
      setState(() {
        latitude = p.latitude;
        longitude = p.longitude;
      });
    } else {
      _setLocalizacaoAtualString(
          map_lib.defaultLatitude, map_lib.defaultLongitude);
      setState(() {
        latitude = map_lib.defaultLatitude;
        longitude = map_lib.defaultLongitude;
      });
      /*setState(() {
        _localizacaoAtual = "Localização indisponível!";
      });*/
    }
  }

  void _setLocalizacaoAtualString(double latitude, double longitude) async {
    String reverseGeocodingString =
        await map_lib.reverseGeocodingString(latitude, longitude);
    setState(() {
      _localizacaoAtual = reverseGeocodingString;
    });
  }

  Future<void> _navigateDefinirLocalizacaoPage(context) async {
    if (latitude == null) {
      latitude = map_lib.defaultLatitude;
      longitude = map_lib.defaultLongitude;
    }

    final LatLong result = await Navigator.pushNamed(
        context, Routes.definirLocalizacao,
        arguments: <String, Object>{
          "latitude": latitude!,
          "longitude": longitude!,
        }) as LatLong;

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!context.mounted) return;

    setState(() {
      latitude = result.latitude;
      longitude = result.longitude;
    });

    _setLocalizacaoAtualString(result.latitude, result.longitude);
  }
  /////////////////////////////////////////////////////////////

  Future<void> _navigateListarProdutosPage(context) async {
    if (_formKey.currentState!.validate() && latitude != null) {
      final Map result = await Navigator.pushNamed(context, Routes.listarProdutos,
          arguments: <String, Object>{
            "palavra": _palavraController.text,
            "latitude": latitude!,
            "longitude": longitude!,
            "localizacao": _localizacaoAtual,
            "distancia": _distancia
          }) as Map<String, Object>;

      
      // When a BuildContext is used from a StatefulWidget, the mounted property
      // must be checked after an asynchronous gap.
      if (!context.mounted) return;

      setState(() {
        _palavraController.text = result['palavra'];
        latitude = result['latitude'];
        longitude = result['longitude'];
        _localizacaoAtual = result['localizacao'];
        _distancia = result['distancia'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                const Expanded(
                    child: Column(children: <Widget>[
                  Image(
                    image: AssetImage('assets/images/pp.png'),
                    height: 150,
                  ),
                  Text(
                    "Premium Price",
                    style: TextStyle(fontSize: 30),
                  ),
                ])),
                Expanded(
                    child: Column(children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: TextFormField(
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Produto:'),
                        controller: _palavraController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Campo não pode ser vazio';
                          }
                          return null;
                        },
                      )),
                  TextButton(
                      onPressed: () {
                        _navigateDefinirLocalizacaoPage(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(child: Text('$_localizacaoAtual (${_distancia}km)')),
                          const Icon(Icons.arrow_drop_down)
                        ],
                      )),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => _navigateListarProdutosPage(context),
                    child: const Text('Pesquisar'),
                  )
                ])),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, Routes.digitalizarNota);
                          },
                          child: const Text("Login"))),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, Routes.confirmarDigitalizacao,
                            arguments: <String, String>{
                              "urlQr":
                                  "https://www.fazenda.pr.gov.br/nfce/qrcode?p=41240778116670001994650110000706859008861151|2|1|19|191.37|36424547706431514c323277326e5933526a4272497a356d31746b3d|1|1E71BE91A8A04C4D104650E2FB2AB5B14CDB91E8"
                            });
                      },
                      child: const Text("Criar Conta")),
                ])
              ],
            )),
      ),
    );
  }
}
