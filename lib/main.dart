import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:papapreco/api/firebase_api.dart';
import 'package:papapreco/misc/auth/auth_provider.dart';
import 'package:papapreco/misc/auth/map_provider.dart';
import 'package:papapreco/service/navigator_service.dart';
import 'package:papapreco/service/notification_service.dart';
import 'package:papapreco/theme/theme.dart';
import 'package:papapreco/view/auth/cadastro_page.dart';
import 'package:papapreco/view/auth/codigo_verificacao_page.dart';
import 'package:papapreco/view/auth/esqueci_senha_page.dart';
import 'package:papapreco/view/auth/esqueci_senha_redefinicao_page.dart';
import 'package:papapreco/view/auth/login_page.dart';
import 'package:papapreco/view/definir_localizacao_page.dart';
import 'package:papapreco/view/produto/cadastrar_produto_page.dart';
import 'package:papapreco/view/produto/qr/confirmar_digitalizacao_page.dart';
import 'package:papapreco/view/produto/detalhe_produto_page.dart';
import 'package:papapreco/view/produto/qr/digitalizar_nota_page.dart';
import 'package:papapreco/view/produto/filtrar_produtos_page.dart';
import 'package:papapreco/view/produto/qr/editar_digitalizacao_page.dart';
import 'package:papapreco/view/produto/qr/inserir_qrcode_page.dart';
import 'package:papapreco/view/produto/listar_produtos_mapa_page.dart';
import 'package:papapreco/view/produto/listar_produtos_page.dart';
import 'package:papapreco/view/produto/sugerir_edicao_page.dart';
import 'package:papapreco/view/usuario/alterar_senha_page.dart';
import 'package:papapreco/view/usuario/alertas_usuario_page.dart';
import 'package:papapreco/widgets/end_drawer.dart';
import 'package:papapreco/widgets/map/definir_localizacao_widget.dart';
import 'package:provider/provider.dart';

import 'routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await FirebaseApi().initNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final auth = AuthProvider();
            auth.loadUser();
            return auth;
          },
        ),
        ChangeNotifierProvider(create: (context) {
          final map = MapProvider();
          map.setCurrentPosition();
          return map;
        }),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Papa Preço',
      theme: appTheme(),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return const MyHomePage(title: 'Papa Preço');
        },
      ),
      routes: {
        Routes.home: (context) => const MyHomePage(title: 'Papa Preço'),
        Routes.digitalizarNota: (context) => const DigitalizarNotaPage(),
        //Routes.login: (context) => const LoginPage(),
        Routes.cadastro: (context) => const CadastroPage(),
        Routes.esqueciSenha: (context) => const EsqueciSenhaPage(),
        Routes.alterarSenha: (context) => const AlterarSenhaPage(),
        Routes.inserirQr: (context) => const InserirQrcodePage(),
        Routes.alertasUsuario: (context) => const AlertasUsuarioPage(),
      },
      onGenerateRoute: (settings) {
        final Map args = settings.arguments as Map<String, Object?>;

        Map routes = <String, WidgetBuilder>{
          Routes.login: (ctx) => LoginPage(
              fromUrl: args["fromUrl"]),
          Routes.definirLocalizacao: (ctx) => DefinirLocalizacaoPage(
              latitude: args["latitude"], longitude: args["longitude"]),
          Routes.listarProdutos: (ctx) =>
              ListarProdutosPage(palavra: args["palavra"]),
          Routes.cadastrarProduto: (ctx) => CadastrarProdutoPage(
              latitude: args["latitude"],
              longitude: args["longitude"],
              localizacaoString: args["localizacaoString"]),
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
              distancia: args["distancia"],
              precoMin: args["precoMin"],
              precoMax: args["precoMax"],
              latitude: args["latitude"],
              longitude: args["longitude"],
              localizacaoString: args["localizacaoString"]),
          Routes.confirmarDigitalizacao: (ctx) =>
              ConfirmarDigitalizacaoPage(urlQr: args["urlQr"]),
          Routes.codigoVerificacao: (ctx) =>
              CodigoVerificacaoPage(email: args["email"], tipo: args["tipo"], senha: args["senha"], fromUrl: args["fromUrl"]),
          Routes.esqueciSenhaRedefinicao: (ctx) => EsqueciSenhaRedefinicaoPage(
              email: args["email"], codigo: args["codigo"]),
          Routes.editarDigitalizacaoPage: (ctx) => EditarDigitalizacaoPage(
              produto: args["produto"])
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

  @override
  void initState() {
    super.initState();
  }

  Future<void> _navigateListarProdutosPage(context) async {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    if (_formKey.currentState!.validate() &&
        mapProvider.localizacaoString != '') {
      final Map result = await Navigator.pushNamed(
              context, Routes.listarProdutos,
              arguments: <String, Object?>{"palavra": _palavraController.text})
          as Map<String, Object?>;

      if (!context.mounted) return;

      setState(() {
        _palavraController.text = result['palavra'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0
      ),
      endDrawer:
          context.watch<AuthProvider>().isLoggedIn ? const EndDrawer() : null,
      body: SingleChildScrollView(
        reverse: true,
              child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8.0),
            child: const Column(
              children: <Widget>[
                Image(
                  image: AssetImage('assets/images/pp.png'),
                  height: 150,
                ),
                Text(
                  "Papa Preço",
                  style: TextStyle(fontSize: 30),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      const Text(
                        'Produto:',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              counterText: ''), 
                          controller: _palavraController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Campo não pode ser vazio';
                            }
                            return null;
                          },
                          maxLength: 256,
                        ),
                      ),
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
                            },
                            futureLocalizacao: true,
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () => _navigateListarProdutosPage(context),
                        child: const Text('Pesquisar'),
                      ),
                    ],
                  )),
        ],
      )),
      bottomNavigationBar: context.watch<AuthProvider>().isLoggedIn
          ? null
          : BottomAppBar(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: OutlinedButton(
                        onPressed: () async {
                          Navigator.pushNamed(context, Routes.login, arguments: <String, Object>{"fromUrl": Routes.home});
                        },
                        child: const Text("Login"),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.cadastro);
                      },
                      child: const Text("Criar Conta"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
