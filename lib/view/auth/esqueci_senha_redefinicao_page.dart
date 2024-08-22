import 'package:flutter/material.dart';
import 'package:premiumprice/helper/error.dart';
import 'package:premiumprice/rest/auth_rest.dart';
import 'package:premiumprice/routes/routes.dart';
import 'package:premiumprice/widgets/auth/senha_e_confirmacao_widget.dart';

class EsqueciSenhaRedefinicaoPage extends StatefulWidget {
  final String email;
  final String token;
  const EsqueciSenhaRedefinicaoPage(
      {super.key, required this.email, required this.token});

  static const String routeName = '/esqueci_senha/redefinicao';

  @override
  State<EsqueciSenhaRedefinicaoPage> createState() =>
      _EsqueciSenhaRedefinicaoPageState();
}

class _EsqueciSenhaRedefinicaoPageState
    extends State<EsqueciSenhaRedefinicaoPage> {
  String _senha = '';
  final _formKey = GlobalKey<FormState>();
  double _passwordStrength = 0.0;
  String _passwordFeedback = '';
  final AuthRest _authRest = AuthRest();

  void _updatePasswordStrength(String password) {
    setState(() {
      _passwordStrength = _calculatePasswordStrength(password);
      _passwordFeedback = _getPasswordFeedback(password);
    });
  }

  double _calculatePasswordStrength(String password) {
    double strength = 0.0;
    if (password.isNotEmpty) strength += 0.1;
    if (password.length >= 8) strength += 0.3;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength += 0.2;
    return strength;
  }

  String _getPasswordFeedback(String password) {
    if (password.isEmpty) return 'A senha é obrigatória';
    if (password.length < 8) return 'A senha deve ter pelo menos 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(password)) return 'Adicione uma letra maiúscula';
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'Adicione um número';
    if (!RegExp(r'[!@#\$&*~]').hasMatch(password)) return 'Adicione um caractere especial';
    return '';
  }

  void _redefinirSenha(context) async {
    try {
      String novaSenha = _senha;
      String retorno = await _authRest.redefinirSenha(widget.email, widget.token, novaSenha);

      if (retorno == 'OK') {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Sucesso!")));
            
        Navigator.popUntil(context, ModalRoute.withName(Routes.login));
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
                
              SenhaEConfirmacaoWidget(onPasswordChanged: (password) {
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
