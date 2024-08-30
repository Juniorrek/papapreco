import 'package:flutter/material.dart';
import 'package:papapreco/helper/error.dart';
import 'package:papapreco/rest/auth_rest.dart';
import 'package:papapreco/routes/routes.dart';

class EsqueciSenhaPage extends StatelessWidget {
  EsqueciSenhaPage({super.key});

  static const String routeName = '/esqueci_senha';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final AuthRest _authRest = AuthRest();

  void _enviarCodigo(context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Impede o fechamento do diálogo ao clicar fora dele
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Enviando código...'),
            ],
          ),
        );
      },
    );
    
    try {
      Future.delayed(const Duration(seconds: 2));

      String email = _emailController.text;
      String retorno =
          await _authRest.recuperarSenhaGerarToken(email);

      // Fechar o diálogo de carregamento
      Navigator.of(context, rootNavigator: true).pop();

      if (retorno == 'OK') {
        bool enviado = await _authRest.enviarCodigoVerificacao(email, "REDEFINIR_SENHA");
        if (enviado) {
          Navigator.pushNamed(
            context, Routes.codigoVerificacao,
            arguments: <String, Object>{
              "email": email,
              "tipo": "REDEFINIR_SENHA",
            });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao enviar código de verificação de email!')),
          );
        }
      } else {
        //Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(retorno)));
      }
    } catch (exception) {
      showError(context, "Erro ", exception.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esqueci Minha Senha'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Digite seu email para recuperar sua senha.',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _enviarCodigo(context);
                    }
                  },
                  child: const Text('Enviar código'),
                ),
              ],
            )),
      ),
    );
  }
}
