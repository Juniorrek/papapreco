import 'package:flutter/material.dart';
import 'package:premiumprice/helper/error.dart';
import 'package:premiumprice/rest/auth_rest.dart';
import 'package:premiumprice/routes/routes.dart';

class EsqueciSenhaCodigoPage extends StatelessWidget {
  final String email;
  EsqueciSenhaCodigoPage({super.key, required this.email});

  static const String routeName = '/esqueci_senha/codigo';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final AuthRest _authRest = AuthRest();

  void _validarCodigo(context) async {
    try {
      String token = _codeController.text;
      String retorno =
          await _authRest.recuperarSenhaValidarToken(email, token);

      if (retorno == 'OK') {
        Navigator.pushNamed(
          context, Routes.esqueciSenhaRedefinicao,
          arguments: <String, Object>{
            "email": email,
            "token": token,
          });
      } else {
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
        title: const Text('Verificação de Código'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Digite o código enviado para seu email.',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Código',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o código';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _validarCodigo(context);
                    }
                  },
                  child: const Text('Verificar código'),
                ),
              ],
            )),
      ),
    );
  }
}
