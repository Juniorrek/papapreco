import 'package:flutter/material.dart';
import 'package:papapreco/helper/error.dart';
import 'package:papapreco/model/usuario.dart';
import 'package:papapreco/rest/auth_rest.dart';
import 'package:papapreco/widgets/auth/senha_e_confirmacao_widget.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  static const String routeName = '/cadastro';

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  String _senha = '';
  final AuthRest _authRest = AuthRest();
  bool _isLoading = false;

  void _cadastrar() async {
    setState(() {
      _isLoading = true;
    });
    try {
      Usuario novoUsuario = Usuario.novo(
          _nomeController.text, _emailController.text, _senha, false);

      novoUsuario = await _authRest.signUp(novoUsuario);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Sucesso!'), behavior: SnackBarBehavior.floating));

      Navigator.pop(context);
    } catch (exception) {
      showError(context, "Erro no cadastro", exception.toString());
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
        title: const Text('Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: CustomScrollView(slivers: [
            SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nome é obrigatório';
                        }
                        return null;
                      },
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
                        if (value == null ||
                            value.isEmpty ||
                            !RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                                .hasMatch(value)) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SenhaEConfirmacaoWidget(
                        labelSenha: "Senha",
                        onPasswordChanged: (password) {
                          setState(() {
                            _senha = password;
                          });
                        }),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (!_isLoading) _cadastrar();
                        }
                      },
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Cadastrar'),
                    ),
                  ],
                ))
          ]),
        ),
      ),
    );
  }
}
