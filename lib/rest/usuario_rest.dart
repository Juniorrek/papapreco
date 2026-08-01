
import 'dart:convert';

import 'package:papapreco/exception/unauthorized_exception.dart';
import 'package:papapreco/model/usuario.dart';
import 'package:http/http.dart' as http;
import 'package:papapreco/rest/api.dart';

class UsuarioRest {
  Future<Usuario> alterarSenha(Usuario usuario, String senhaAtual, String token) async {
    final http.Response response = await http.put(
      API.uri('usuarios/alterarSenha'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        "usuarioId": usuario.id.toString(),
        "senhaNova": usuario.senha!,
        "senhaAtual": senhaAtual
      }));

    if (response.statusCode == 200) {
      return Usuario.fromJson(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido ou expirado.');
    } else {
      throw Exception(response.body);
    }
  }

  Future<Usuario> alterarLocalizacaoAlertas(Usuario usuario, String token) async {
    final http.Response response = await http.put(
      API.uri('usuarios/alterarLocalizacaoAlertas'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: usuario.toJson());

    if (response.statusCode == 200) {
      return Usuario.fromJson(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido ou expirado.');
    } else {
      throw Exception(response.body);
    }
  }
}