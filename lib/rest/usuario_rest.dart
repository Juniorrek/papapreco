
import 'dart:convert';

import 'package:papapreco/model/usuario.dart';
import 'package:http/http.dart' as http;
import 'package:papapreco/rest/api.dart';

class UsuarioRest {
  Future<Usuario?> alterarSenha(Usuario usuario, String senhaAtual, String? token) async {
    if (token == null) {
      throw Exception('Usuário não está autenticado.');
    }
    
    final http.Response response = await http.put(
      Uri.http(API.endpoint, '${API.name}/usuario/alterarSenha'),
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
    } else if (response.statusCode == 403) {
      return null;
    } else {
      throw Exception(response.body);
    }
  }
}