import 'package:flutter/material.dart';
import 'package:papapreco/helper/error.dart';
import 'package:papapreco/rest/auth_rest.dart';
import 'package:papapreco/routes/routes.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'dart:async';

import 'package:papapreco/util/login_util.dart'; // Importar para usar o Timer

class CodigoVerificacaoPage extends StatefulWidget {
  final String email;
  final String tipo;
  final String? senha;
  final String? fromUrl;

  const CodigoVerificacaoPage(
      {super.key, required this.email, required this.tipo, this.senha, this.fromUrl});

  static const String routeName = '/codigo_verificacao';

  @override
  State<CodigoVerificacaoPage> createState() => _CodigoVerificacaoPageState();
}

class _CodigoVerificacaoPageState extends State<CodigoVerificacaoPage> {
  final _formKey = GlobalKey<FormState>();
  final MaskedTextController _codeController =
      MaskedTextController(mask: '***-***');
  final AuthRest _authRest = AuthRest();

  bool _showResendButton = false;
  bool _isLoading = false;

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
    setState(() {
      _isLoading = true;
    });
    try {
      String codigo = _codeController.text;
      String retorno =
          await _authRest.validarCodigoVerificacao(widget.email, codigo);

      if (retorno == 'OK') {
        if (widget.tipo == "VERIFICAR_EMAIL") {
          await _authRest.verificarEmail(widget.email, codigo);
          /*ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Email verificado com sucesso!"), behavior: SnackBarBehavior.floating));*/
          
          //Navigator.pushNamed(context, Routes.login);


          LoginUtil.logar(context, widget.email, widget.senha!, widget.fromUrl!);
        } else if (widget.tipo == "REDEFINIR_SENHA") {
          Navigator.pushNamed(context, Routes.esqueciSenhaRedefinicao,
              arguments: <String, Object>{
                "email": widget.email,
                "codigo": codigo,
              });
        }
      } else {
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

  Widget _loadingWidget() {
    return const AlertDialog(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('Carregando...'),
        ],
      ),
    );
  }

  Future<void> _reenviarCodigo() async {
    setState(() {
      _isLoading = true;
    });
    try {
      bool enviado = await _authRest.enviarCodigoVerificacao(
          widget.email, widget.tipo);
      if (enviado) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enviado com sucesso!'), behavior: SnackBarBehavior.floating),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Erro ao enviar código de verificação de email!'), behavior: SnackBarBehavior.floating),
          );
        }
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        child: _isLoading
            ? _loadingWidget()
            : Form(
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
                          _reenviarCodigo();
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
