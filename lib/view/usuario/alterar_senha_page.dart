import 'package:flutter/material.dart';
import 'package:papapreco/helper/error.dart';
import 'package:papapreco/misc/auth/auth_provider.dart';
import 'package:papapreco/model/usuario.dart';
import 'package:papapreco/rest/usuario_rest.dart';
import 'package:papapreco/routes/routes.dart';
import 'package:papapreco/widgets/auth/senha_e_confirmacao_widget.dart';
import 'package:provider/provider.dart';

class AlterarSenhaPage extends StatefulWidget {
  const AlterarSenhaPage({super.key});

  static const String routeName = '/usuario/alterar_senha';

  @override
  State<AlterarSenhaPage> createState() => _AlterarSenhaPageState();
}

class _AlterarSenhaPageState extends State<AlterarSenhaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  String _senha = '';
  final UsuarioRest _usuarioRest = UsuarioRest();

  void _alterarSenha(context) async {
    try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        String? token = authProvider.token;
        Usuario? usuario = authProvider.usuario;

        if (token == null || usuario == null) return;

        usuario.senha = _senha;
        Usuario? u = await _usuarioRest.alterarSenha(usuario, _currentPasswordController.text, token);

        if (u == null) {
          authProvider.logout();

          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Login expirado!")));

          //Navigator.pushReplacementNamed(context, Routes.home);
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.home,
            (Route<dynamic> route) => false, // Remove todas as rotas da pilha
          );
        } else {

          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Sucesso!")));
              
          Navigator.pop(context);
        }
    } catch (exception) {
      showError(context, "Erro ", exception.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar Senha'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Digite sua nova senha.',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                TextFormField(
                controller: _currentPasswordController,
          obscureText: true,
                decoration: const InputDecoration(
            labelText: 'Senha Atual',
            border: OutlineInputBorder(),
          ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha atual.';
                  }
                  // Aqui você pode adicionar validação adicional, como checar se a senha está correta
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              SenhaEConfirmacaoWidget(labelSenha: "Nova Senha", onPasswordChanged: (password) {
                setState(() {
                  _senha = password;
                });
              }),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                        _alterarSenha(context);
                      }
                  },
                  child: const Text('Alterar Senha'),
                ),
              ],
            )),
      ),
    );
  }
}
