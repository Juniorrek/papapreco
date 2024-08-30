import 'package:flutter/material.dart';
import 'package:papapreco/exception/unauthorized_exception.dart';
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
  bool _isLoading = false;


  void _alterarSenha(context) async {
    setState(() {
      _isLoading = true;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      showError(context, "Erro", "Token de autenticação não encontrado.");
      return;
    }

    try {
        Usuario usuario = authProvider.usuario!;
        usuario.senha = _senha;
        Usuario u = await _usuarioRest.alterarSenha(usuario, _currentPasswordController.text, token);

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Sucesso!")));
            
        Navigator.pop(context);
        Navigator.pop(context);
    } on UnauthorizedException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login expirado, entre novamente!')),
      );
      Navigator.pushNamed(context, Routes.login);
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
                  onPressed: _isLoading
                            ? null
                            :() {
                    if (_formKey.currentState?.validate() ?? false) {
                        _alterarSenha(context);
                      }
                  },
                  child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                ),
                              )
                            : const Text('Alterar Senha'),
                ),
              ],
            )),
      ),
    );
  }
}
