import 'package:flutter/material.dart';
import 'package:papapreco/misc/auth/auth_provider.dart';
import 'package:papapreco/model/usuario.dart';
import 'package:papapreco/rest/auth_rest.dart';
import 'package:papapreco/routes/routes.dart';
import 'package:provider/provider.dart';

mixin LoginMixin {
  final AuthRest _aRest = AuthRest();
  
   void _logar(BuildContext context, String email, String senha) async {
    try {
      dynamic retorno = await _aRest.signIn(email, senha);

      if (!context.mounted) return;

      if (retorno is Map) {
        await _processarLogin(context, retorno);
      } else {
        await _tratarErroLogin(context, retorno, email);
      }
    } catch (exception) {
      if (!context.mounted) return;
      _exibirSnackBar(context, 'Erro inesperado!');
    }
  }

  Future<void> _processarLogin(BuildContext context, Map retorno) async {
    Usuario u = Usuario.fromMap(retorno['usuario']);
    await context.read<AuthProvider>().login(retorno['accessToken'], u);

    _exibirSnackBar(context, 'Logado com sucesso.');
    _navegarParaHome(context);
  }

  Future<void> _tratarErroLogin(BuildContext context, dynamic retorno, String email) async {
    if (retorno == 'Email não verificado!') {

      bool enviado =
          await _aRest.enviarCodigoVerificacao(email, "VERIFICAR_EMAIL");
      if (enviado) {
        _navegarParaCodigoVerificacao(context, email);
      } else {
        _exibirSnackBar(context, 'Erro ao enviar código de verificação de email!');
      }
    } else {
      _exibirSnackBar(context, retorno as String);
    }
  }

  void _exibirSnackBar(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), behavior: SnackBarBehavior.floating),
    );
  }

  void _navegarParaHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  void _navegarParaCodigoVerificacao(BuildContext context, String email) {
    _exibirSnackBar(context, 'Email não verificado! Verifique a caixa de email!');
    Navigator.pushNamed(
      context,
      Routes.codigoVerificacao,
      arguments: <String, Object>{
        "email": email,
        "tipo": "VERIFICAR_EMAIL",
      },
    );
  }
}