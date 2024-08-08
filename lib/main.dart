import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_linux/geolocator_linux.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:premiumprice/mixin/map_mixin.dart';
import 'package:premiumprice/util/map_util.dart';
import 'package:premiumprice/view/definir_localizacao_page.dart';
import 'package:premiumprice/view/produto/listar_produtos_mapa_page.dart';
import 'package:premiumprice/view/produto/listar_produtos_page.dart';

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
        Routes.definirLocalizacao: (context) => const DefinirLocalizacaoPage()
      },
      onGenerateRoute: (settings) {
        final Map args = settings.arguments as Map<String, String>;

        Map routes = <String, WidgetBuilder>{
          Routes.listarProdutos: (ctx) => ListarProdutosPage(
            nomeProduto: args["nomeProduto"],
            latitude: double.parse(args["latitude"]),
            longitude: double.parse(args["longitude"])
          ),
          Routes.listarProdutosMapa: (ctx) => ListarProdutosMapaPage(
            nomeProduto: args["nomeProduto"],
            latitude: double.parse(args["latitude"]),
            longitude: double.parse(args["longitude"])
          ),
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

class _MyHomePageState extends State<MyHomePage> with MapMixin {
  final _formKey = GlobalKey<FormState>();

  final _nomeProdutoController = TextEditingController();

  String _localizacaoAtual = '';

  double? latitude = null;
  double? longitude = null;

  @override
  void initState() {
    super.initState();

    _setCurrentPosition();
  }

  //NÃO CONSIGO JOGAR NA UTIL PQ PRA CHAMAR NA INITSTATE PRECISA SER ASYNC
  //ENTÃO POR ENQUANTO CODIGO DUPLICADO
  /////////////////////////////////////////////////////////////
  Future<void> _setCurrentPosition() async {
    //Position p = await MapUtil.currentLocation();

    Position? p = await currentLocation();

    if (p != null) {
      _setLocalizacaoAtualString(p.latitude, p.longitude);
      setState(() {
        latitude = p.latitude;
        longitude = p.longitude;
      });
    } else {
      setState(() {
        _localizacaoAtual = "Localização indisponível!";
      });
    }
  }

  void _setLocalizacaoAtualString(double latitude, double longitude) async {
    String reverseGeocodingString =
        await MapUtil.reverseGeocodingString(latitude, longitude);
    setState(() {
      _localizacaoAtual = reverseGeocodingString;
    });
  }

  _navigateDefinirLocalizacaoPage(context) async {
    final LatLong result =
        await Navigator.pushNamed(context, Routes.definirLocalizacao)
            as LatLong;

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
                        controller: _nomeProdutoController,
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
                          Flexible(child: Text('$_localizacaoAtual (5km)')),
                          const Icon(Icons.arrow_drop_down)
                        ],
                      )),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          latitude != null) {
                        Navigator.pushNamed(
                            context, Routes.listarProdutos,
                            arguments: <String, String>{
                              "nomeProduto": _nomeProdutoController.text,
                              "latitude": latitude.toString(),
                              "longitude": longitude.toString()
                            });
                      }
                    },
                    child: const Text('Pesquisar'),
                  )
                ])),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: ElevatedButton(
                          onPressed: () {}, child: const Text("Login"))),
                  ElevatedButton(
                      onPressed: () {}, child: const Text("Criar Conta")),
                ])
              ],
            )),
      ),
    );
  }
}
