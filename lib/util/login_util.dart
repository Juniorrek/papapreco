import 'package:flutter/material.dart';
import 'package:papapreco/misc/auth/auth_provider.dart';
import 'package:papapreco/model/usuario.dart';
import 'package:papapreco/rest/auth_rest.dart';
import 'package:papapreco/routes/routes.dart';
import 'package:provider/provider.dart';

class LoginUtil {
  static final AuthRest _aRest = AuthRest();
  
  static Future<void> logar(BuildContext context, String email, String senha, String retornoUrl) async {
    try {
      dynamic retorno = await _aRest.signIn(email, senha);

      if (!context.mounted) return;

      if (retorno is Map) {
        await _processarLogin(context, retorno, retornoUrl);
      } else {
        await _tratarErroLogin(context, retorno, email, senha);
      }
    } catch (exception) {
      if (!context.mounted) return;
      _exibirSnackBar(context, 'Erro inesperado!');
    }
  }

  static Future<void> _processarLogin(BuildContext context, Map retorno, String retornoUrl) async {
    Usuario u = Usuario.fromMap(retorno['usuario']);
    await context.read<AuthProvider>().login(retorno['accessToken'], u);

    _exibirSnackBar(context, 'Logado com sucesso.');
    //Navigator.pushReplacementNamed(context, retornoUrl);
    //Navigator.popUntil(context, ModalRoute.withName(retornoUrl));
    //TODO: fromUrl
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  static Future<void> _tratarErroLogin(BuildContext context, dynamic retorno, String email, String senha) async {
    if (retorno == 'Email não verificado!') {
      _exibirSnackBar(context, 'Email não verificado! Verifique a caixa de email!');

      bool enviado =
          await _aRest.enviarCodigoVerificacao(email, "VERIFICAR_EMAIL");
      if (enviado) {
        _navegarParaCodigoVerificacao(context, email, senha);
      } else {
        _exibirSnackBar(context, 'Erro ao enviar código de verificação de email!');
      }
    } else {
      _exibirSnackBar(context, retorno as String);
    }
  }

  static void _exibirSnackBar(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), behavior: SnackBarBehavior.floating),
    );
  }

  static void _navegarParaCodigoVerificacao(BuildContext context, String email, String senha) {
    Navigator.pushNamed(
      context,
      Routes.codigoVerificacao,
      arguments: <String, Object>{
        "email": email,
        "tipo": "VERIFICAR_EMAIL",
        "senha": senha,
        "fromUrl": Routes.home
      },
    );
  }
}