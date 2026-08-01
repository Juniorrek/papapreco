import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:papapreco/exception/unauthorized_exception.dart';
import 'package:papapreco/model/voto_usuario_produto.dart';
import 'package:papapreco/rest/api.dart';

class VotoUsuarioProdutoRest {
  Future<VotoUsuarioProduto> buscarPorId(int id) async {
    final http.Response response =
        await http.get(API.uri('voto/$id'));

    if (response.statusCode == 200) {
      VotoUsuarioProduto v = VotoUsuarioProduto.fromJson(response.body);
      return v;
    } else {
      throw Exception('Erro buscando o voto por id.');
    }
  }

  Future<VotoUsuarioProduto> votar(int produtoId, int usuarioId, bool voto, String accessToken) async {
    final http.Response response = await http.post(
      API.uri('votar'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
      'produtoId': produtoId,
      'usuarioId': usuarioId,
      'voto': voto,
    }));

    if (response.statusCode == 200) {
      return VotoUsuarioProduto.fromJson(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido ou expirado.');
    } else {
      throw Exception('Erro inserindo voto.');
    }
  }

  Future<VotoUsuarioProduto> mudarVoto(int produtoId, int usuarioId, bool novoVoto, String accessToken) async {
    final http.Response response = await http.put(
      API.uri('voto/$usuarioId/$produtoId', {'novoVoto': novoVoto}),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      });

    if (response.statusCode == 200) {
      return VotoUsuarioProduto.fromJson(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido ou expirado.');
    } else {
      throw Exception('Erro atualizando voto.');
    }
  }

  Future<void> cancelarVoto(int produtoId, int usuarioId, String accessToken) async {
    final http.Response response = await http.delete(
      API.uri('voto/$usuarioId/$produtoId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      });

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido ou expirado.');
    } else {
      throw Exception('Erro cancelando voto.');
    }
  }
}
