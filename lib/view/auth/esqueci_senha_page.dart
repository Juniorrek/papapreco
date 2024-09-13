import 'package:flutter/material.dart';
import 'package:papapreco/helper/error.dart';
import 'package:papapreco/rest/auth_rest.dart';
import 'package:papapreco/routes/routes.dart';
import 'package:papapreco/view/auth/codigo_verificacao_page.dart';

class EsqueciSenhaPage extends StatefulWidget {
  const EsqueciSenhaPage(
      {super.key});

  static const String routeName = '/esqueci_senha';

  @override
  State<EsqueciSenhaPage> createState() => _EsqueciSenhaPageState();
}

class _EsqueciSenhaPageState extends State<EsqueciSenhaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final AuthRest _authRest = AuthRest();
  bool _isLoading = false;

  Future<void> _enviarCodigo() async {
    setState(() {
      _isLoading = true;
    });
    try {
      Future.delayed(const Duration(seconds: 2));

      String email = _emailController.text;
      String retorno =
          await _authRest.recuperarSenhaGerarToken(email);

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
            const SnackBar(content: Text('Erro ao enviar código de verificação de email!'), behavior: SnackBarBehavior.floating),
          );
        }
      } else {
        //Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(retorno), behavior: SnackBarBehavior.floating));
      }
    } catch (exception) {
      showError(context, "Erro ", exception.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
        child: _isLoading
                            ? _loadingWidget()
                            :Form(
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
                      _enviarCodigo();
                    }
                  },
                  child: const Text('Enviar código'),
                ),
              ],
            )),
      ),
    );
  }

  Widget _loadingWidget() {
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
  }
}
