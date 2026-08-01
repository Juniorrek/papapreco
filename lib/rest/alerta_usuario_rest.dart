import 'package:http/http.dart' as http;
import 'package:papapreco/exception/unauthorized_exception.dart';
import 'package:papapreco/model/alerta_usuario.dart';
import 'package:papapreco/rest/api.dart';

class AlertaUsuarioRest {
  Future<List<AlertaUsuario>> buscarPorUsuario(int usuarioId, String token) async {
    final http.Response response =
        await http.get(API.uri('alertas/usuario/$usuarioId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        });

    if (response.statusCode == 200) {
      List<AlertaUsuario> produtos = AlertaUsuario.fromJsonList(response.body);
      return produtos;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido ou expirado.');
    } else {
      throw Exception('Erro buscando as notificações do usuário.');
    }
  }

  Future<AlertaUsuario> inserir(AlertaUsuario alerta, String token) async {
    final http.Response response =
        await http.post(API.uri('alertas'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
            body: alerta.toJson());
            
    if (response.statusCode == 200) {
      return AlertaUsuario.fromJson(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido ou expirado.');
    } else {
      throw Exception('Erro inserindo alerta.');
    }
  }

  Future<AlertaUsuario> alterar(AlertaUsuario alerta, String token) async {
    final http.Response response = await http.put(
      API.uri('alertas/${alerta.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: alerta.toJson(),
    );
    if (response.statusCode == 200) {
      return alerta;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido ou expirado.');
    } else {
      throw Exception('Erro alterando alerta ${alerta.id}.');
    }
  }

  Future<AlertaUsuario> remover(int id, String token) async {
    final http.Response response = await http
        .delete(API.uri('alertas/$id'),
      headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      return AlertaUsuario.fromJson(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido ou expirado.');
    } else {
      throw Exception('Erro removendo alerta: $id.');
    }
  }
}