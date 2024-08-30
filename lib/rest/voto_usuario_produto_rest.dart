import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:papapreco/model/voto_usuario_produto.dart';
import 'package:papapreco/rest/api.dart';

class VotoUsuarioProdutoRest {
  Future<VotoUsuarioProduto> buscarPorId(int id) async {
    final http.Response response =
        await http.get(Uri.http(API.endpoint, "voto/$id"));

    if (response.statusCode == 200) {
      VotoUsuarioProduto v = VotoUsuarioProduto.fromJson(response.body);
      return v;
    } else {
      throw Exception('Erro buscando o voto por id.');
    }
  }

  Future<VotoUsuarioProduto> votar(int produtoId, int usuarioId, bool voto) async {
    final http.Response response = await http.post(
      Uri.http(API.endpoint, 'votar'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
      'produtoId': produtoId,
      'usuarioId': usuarioId,
      'voto': voto,
    }));

    if (response.statusCode == 200) {
      return VotoUsuarioProduto.fromJson(response.body);
    } else {
      throw Exception('Erro inserindo voto.');
    }
  }

  Future<VotoUsuarioProduto> mudarVoto(int produtoId, int usuarioId, bool novoVoto) async {
    final http.Response response = await http.put(
      Uri.parse('http://${API.endpoint}/voto/$usuarioId/$produtoId?novoVoto=$novoVoto'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      });

    if (response.statusCode == 200) {
      return VotoUsuarioProduto.fromJson(response.body);
    } else {
      throw Exception('Erro atualizando voto.');
    }
  }
}
