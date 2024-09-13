import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:papapreco/misc/auth/auth_provider.dart';
import 'package:papapreco/model/usuario.dart';
import 'package:papapreco/rest/auth_rest.dart';
import 'package:papapreco/routes/routes.dart';
import 'package:papapreco/view/auth/codigo_verificacao_page.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final AuthRest _authRest = AuthRest();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '736661748519-433ei1nefrp6m1f0k3forqbh904r8oac.apps.googleusercontent.com',
    scopes: [
      'email',
      /*'profile',
      'openid'*/
    ],
  );

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _signInGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      /* 
      TODO: remove this after testing was finished,
      this lets you pick your account in every login attempt 
      */
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final String? idToken = googleAuth.idToken;

        Map a = await _authRest.signInGoogle(idToken!, googleAuth.accessToken!);

        Usuario u = Usuario.fromMap(a['usuario']);

        if (!mounted) return;

        await context.read<AuthProvider>().login(a['accessToken'], u);

        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Logado com sucesso.'), behavior: SnackBarBehavior.floating));

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, Routes.home);
      }
    } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Erro de conexão.'), behavior: SnackBarBehavior.floating));
      //print('EROO $e');
    } finally {
    setState(() {
      _isLoading = false;
    });
    }
  }

  void _logar() async {
    try {
      String email = _emailController.text;
      dynamic retorno = await _authRest.signIn(email, _senhaController.text);

      if (!mounted) return;

      if (retorno is Map) {
        await _processarLogin(retorno);
      } else {
        await _tratarErroLogin(retorno, email);
      }
    } catch (exception) {
      if (!mounted) return;
      _exibirSnackBar('Erro inesperado!');
    }
  }

  Future<void> _processarLogin(Map retorno) async {
    Usuario u = Usuario.fromMap(retorno['usuario']);
    await context.read<AuthProvider>().login(retorno['accessToken'], u);

    _exibirSnackBar('Logado com sucesso.');
    _navegarParaHome();
  }

  Future<void> _tratarErroLogin(dynamic retorno, String email) async {
    if (retorno == 'Email não verificado!') {
      _exibirSnackBar('Email não verificado! Verifique a caixa de email!');

      bool enviado =
          await _authRest.enviarCodigoVerificacao(email, "VERIFICAR_EMAIL");
      if (enviado) {
        _navegarParaCodigoVerificacao(email);
      } else {
        _exibirSnackBar('Erro ao enviar código de verificação de email!');
      }
    } else {
      _exibirSnackBar(retorno as String);
    }
  }

  void _exibirSnackBar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), behavior: SnackBarBehavior.floating),
    );
  }

  void _navegarParaHome() {
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  void _navegarParaCodigoVerificacao(String email) {
    Navigator.pushNamed(
      context,
      Routes.codigoVerificacao,
      arguments: <String, Object>{
        "email": email,
        "tipo": "VERIFICAR_EMAIL",
      },
    );
  }
  

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
        title: const Text('Login'),
        scrolledUnderElevation: 0
      );

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      appBar: appBar,
      body: 
      SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8),child: 
           SizedBox(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - appBar.preferredSize.height,
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Center(
              child: Text(
                "Papa Preço",
                style: TextStyle(fontSize: 30),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Obrigatório';
                        }
                        return null;
                      }),
                  const SizedBox(height: 16),
                  TextFormField(
                      controller: _senhaController,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Obrigatório';
                        }
                        return null;
                      }),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _logar();
                      }
                    },
                    child: const Text('Entrar'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            ElevatedButton.icon(
              icon: const FaIcon(
                FontAwesomeIcons.google,
                color: Colors.red,
                size: 24.0,
              ),
              label: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                ),
                              )
                            :const Text(
                'Entrar com a conta Google',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              onPressed: _isLoading
                            ? null
                            :() => _signInGoogle(),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.black, width: 1.0),
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            /*Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.google),
                  iconSize: 35,
                  onPressed: () {
                    _signInGoogle();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.facebook),
                  iconSize: 35,
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),*/
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.esqueciSenha);
                  },
                  child: const Text('Esqueci minha senha'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.cadastro);
                  },
                  child: const Text('Criar conta'),
                ),
              ],
            ),
          ],
        ))),
      ),
    );
  }
}
