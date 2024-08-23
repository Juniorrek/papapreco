import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:premiumprice/misc/auth/auth_provider.dart';
import 'package:premiumprice/model/usuario.dart';
import 'package:premiumprice/rest/auth_rest.dart';
import 'package:premiumprice/routes/routes.dart';
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
  

  @override
  void initState() {
    super.initState();
  }

  void _logar() async {
    try {
      Map a = await _authRest.signIn(_emailController.text, _senhaController.text);

      Usuario u = Usuario.fromMap(a['usuario']);

      if (!mounted) return;
      await context.read<AuthProvider>().login(a['token'], u);


      /*ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logado com sucesso.')));*/


      if (!mounted) return;
          Navigator.pushReplacementNamed(context, Routes.home);
    } catch (exception) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email ou senha inválidos!')));
      //showError(context, "Erro no login", exception.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                "Premium Price",
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
                }
                  ),
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
                }
                  ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.google),
                  iconSize: 25,
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.facebook),
                  iconSize: 25,
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                        context, Routes.esqueciSenha);
                  },
                  child: const Text('Esqueci minha senha'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                        context, Routes.cadastro);
                  },
                  child: const Text('Criar conta'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
