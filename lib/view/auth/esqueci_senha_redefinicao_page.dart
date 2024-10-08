import 'package:flutter/material.dart';
import 'package:papapreco/helper/error.dart';
import 'package:papapreco/rest/auth_rest.dart';
import 'package:papapreco/routes/routes.dart';
import 'package:papapreco/widgets/auth/senha_e_confirmacao_widget.dart';

class EsqueciSenhaRedefinicaoPage extends StatefulWidget {
  final String email;
  final String codigo;
  const EsqueciSenhaRedefinicaoPage(
      {super.key, required this.email, required this.codigo});

  static const String routeName = '/esqueci_senha/redefinicao';

  @override
  State<EsqueciSenhaRedefinicaoPage> createState() =>
      _EsqueciSenhaRedefinicaoPageState();
}

class _EsqueciSenhaRedefinicaoPageState
    extends State<EsqueciSenhaRedefinicaoPage> {
  String _senha = '';
  final _formKey = GlobalKey<FormState>();
  final AuthRest _authRest = AuthRest();

  void _redefinirSenha(context) async {
    try {
      String novaSenha = _senha;
      String retorno = await _authRest.redefinirSenha(widget.email, widget.codigo, novaSenha);

      if (retorno == 'OK') {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Sucesso!"), behavior: SnackBarBehavior.floating));
            
        //Navigator.popUntil(context, ModalRoute.withName(Routes.login));
        Navigator.pushReplacementNamed(context, Routes.home);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(retorno), behavior: SnackBarBehavior.floating));
      }
    } catch (exception) {
      showError(context, "Erro ", exception.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redefinir Senha'),
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
                
              SenhaEConfirmacaoWidget(labelSenha: "Senha", onPasswordChanged: (password) {
                setState(() {
                  _senha = password;
                });
              }),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                        _redefinirSenha(context);
                      }
                  },
                  child: const Text('Redefinir Senha'),
                ),
              ],
            )),
      ),
    );
  }
}
