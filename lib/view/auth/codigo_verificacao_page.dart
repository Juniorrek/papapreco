import 'package:flutter/material.dart';
import 'package:papapreco/helper/error.dart';
import 'package:papapreco/rest/auth_rest.dart';
import 'package:papapreco/routes/routes.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'dart:async'; // Importar para usar o Timer

enum TipoCodigoVerificacao {
  verificarEmail,
  redefinirSenha
}

class CodigoVerificacaoPage extends StatefulWidget {
  final String email;
  final TipoCodigoVerificacao tipo;

  const CodigoVerificacaoPage({super.key, required this.email, required this.tipo});

  static const String routeName = '/codigo_verificacao';

  @override
  State<CodigoVerificacaoPage> createState() => _CodigoVerificacaoPageState();
}

class _CodigoVerificacaoPageState extends State<CodigoVerificacaoPage> {
  final _formKey = GlobalKey<FormState>();
  final MaskedTextController _codeController = MaskedTextController(mask: '***-***');
  final AuthRest _authRest = AuthRest();

  bool _showResendButton = false;

  @override
  void initState() {
    super.initState();
    // Configurar o Timer para alterar a visibilidade do botão após 5 segundos
    Timer(const Duration(seconds: 5), () {
      setState(() {
        _showResendButton = true;
      });
    });
  }

  void _validarCodigo(context) async {
    try {
      String codigo = _codeController.text;
      String retorno =
          await _authRest.validarCodigoVerificacao(widget.email, codigo);

      if (retorno == 'OK') {
        if (widget.tipo == TipoCodigoVerificacao.verificarEmail) {

          await _authRest.verificarEmail(widget.email, codigo);
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Email verificado com sucesso!")));
          Navigator.pushNamed(context, Routes.login);
        } else if (widget.tipo == TipoCodigoVerificacao.redefinirSenha) {
          Navigator.pushNamed(
            context, Routes.esqueciSenhaRedefinicao,
            arguments: <String, Object>{
              "email": widget.email,
              "codigo": codigo,
            });
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(retorno)));
      }
    } catch (exception) {
      showError(context, "Erro ", exception.toString());
    }
  }

  Future<void> _reenviarCodigo() async {
      bool enviado =
          await _authRest.enviarCodigoVerificacao(widget.email, widget.tipo.name);
      if (enviado) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enviado com sucesso!')),
        );
        }
      } else {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao enviar código de verificação de email!')),
          );
        }
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
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Código',
                    border: OutlineInputBorder(),
                    hintText: 'ABC-000',
                  ),
                  //keyboardType: TextInputType.number,
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
                const SizedBox(height: 16),
                // Adicionar o TextButton que aparece após 5 segundos
                Visibility(
                  visible: _showResendButton,
                  child: TextButton(
                    onPressed: () {
                      _reenviarCodigo;
                    },
                    child: const Text('Reenviar código'),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
