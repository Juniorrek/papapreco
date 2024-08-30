import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:papapreco/exception/unauthorized_exception.dart';
import 'package:papapreco/model/localizacao.dart';
import 'package:papapreco/model/produto.dart';
import 'package:papapreco/model/usuario.dart';
import 'package:papapreco/rest/api.dart';
import 'package:papapreco/misc/map/map_lib.dart' as map_lib;

class ProdutoRest {
  Future<Produto> buscarPorId(int id) async {
    final http.Response response =
        await http.get(Uri.parse("http://${API.endpoint}/${API.name}/produtos/$id"));

    if (response.statusCode == 200) {
      Produto p = Produto.fromJson(response.body);
     // String localizacaoString = await map_lib.reverseGeocodingShop(p.localizacao.latitude, p.localizacao.longitude);
      //p.localizacao = Localizacao.novo(p.localizacao.latitude, p.localizacao.longitude, localizacaoString);
      return p;
    } else {
      throw Exception('Erro buscando o produto por id.');
    }
  }

  Future<List<Produto>> buscarPorNome(String nome) async {
    final http.Response response =
        await http.get(Uri.http(API.endpoint, "produtos/nome/$nome"));

    if (response.statusCode == 200) {
      List<Produto> produtos = Produto.fromJsonList(response.body);

      //TODO: Melhorar, pode ficar lento
      // LIMITAR A QUANTIDADE OU VERIFICAR SE NO BACK NAO É MELHOR
      /*for (Produto p in produtos) {
        p.localizacao = await map_lib.reverseGeocodingShop(p.latitude, p.longitude);
      }*/

      return produtos;
    } else {
      throw Exception('Erro buscando os produtos por nome.');
    }
  }

  Future<List<Produto>> filtrar(String nome, double latitude, double longitude, double distancia, double precoMin, double precoMax) async {
    final http.Response response =
        await http.get(Uri.parse("http://${API.endpoint}/produtos/filtrar?nome=$nome&latitude=$latitude&longitude=$longitude&distancia=$distancia&precoMin=$precoMin&precoMax=$precoMax"));

    if (response.statusCode == 200) {
      List<Produto> produtos = Produto.fromJsonList(response.body);

      return produtos;
    } else {
      throw Exception('Erro filtrando os produtos.');
    }
  }

  Future<List<Produto>> ranking(String palavra, double latitude, double longitude, double distancia, Decimal precoMin, Decimal precoMax) async {
    final http.Response response =
        await http.get(Uri.parse("http://${API.endpoint}/${API.name}/produtos/ranking?palavra=$palavra&latitude=$latitude&longitude=$longitude&distancia=$distancia&precoMin=$precoMin&precoMax=$precoMax"));

    if (response.statusCode == 200) {
      List<Produto> produtos = Produto.fromJsonList(response.body);

      return produtos;
    } else {
      throw Exception('Erro ranking os produtos.');
    }
  }

  Future<List<Produto>> historico(String nome, double latitude, double longitude) async {
    final http.Response response =
        await http.get(Uri.parse("http://${API.endpoint}/${API.name}/produtos/historico?nome=$nome&latitude=$latitude&longitude=$longitude"));

    if (response.statusCode == 200) {
      List<Produto> produtos = Produto.fromJsonList(response.body);

      return produtos;
    } else {
      throw Exception('Erro historico os produtos.');
    }
  }

  Future<List<Produto>> buscarPorUrlQrNFCeFazenda(String urlQr, Usuario u) async {
    final http.Response response = await http.get(Uri.parse(urlQr));

    if (response.statusCode == 200) {
      var document = parse(response.body);

      //minerando localizacao
      var localizacao =
          document.getElementsByClassName("txtCenter").first.children[2].text;
      var geo = await map_lib.geocoding(localizacao);
      double lat = double.parse(geo[0]["lat"]);
      double lon = double.parse(geo[0]["lon"]);
      String localizacaoString = await map_lib.reverseGeocodingShop(lat, lon);

      //minerando data
      var infoNota = document.getElementById("infos");
      var dadosNota = infoNota?.children.first.children[1].children.first.text;
      final regex = RegExp(r'\b\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2}\b');
      final match = regex.firstMatch(dadosNota!);

      final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
      String dateString = match!.group(0)!;
      final dateTime = dateFormat.parse(dateString);

      //minerando produtos
      var table = document.getElementById("tabResult");
      var trs = table?.children.first.children;

      List<Produto> produtos = [];
      RegExp exp = RegExp(r'[0-9]+,[0-9]+');
      if (trs != null) {
        for (final tr in trs) {
          produtos.add(Produto.novo(
              tr.getElementsByClassName("txtTit2").first.text,
              null,
              Decimal.parse(exp
                  .firstMatch(
                      tr.getElementsByClassName("RvlUnit").first.text)![0]!
                  .replaceAll(",", ".")
              ),
              Localizacao.novo(lat, lon, localizacaoString),
              DateTime.now(),
              dateTime,
              u));
        }
      }

      //remove duplicados
      var seen = <String>{};
      produtos = produtos.where((p) => seen.add(p.nome)).toList();

      return produtos;
    } else {
      throw Exception('Erro buscando os produtos do QR CODE.');
    }
  }

  Future<Produto> inserir(Produto produto, String token) async {
    final http.Response response = await http.post(
      Uri.parse("http://${API.endpoint}/${API.name}/produtos"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: produto.toJson(),
    );
    if (response.statusCode == 200) {
      return Produto.fromJson(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido ou expirado.');
    } else {
      throw Exception('Erro inserindo produto ${produto.id}.');
    }
  }

  Future<void> inserirLista(List<Produto> produtos, String token) async {
    final http.Response response = await http.post(
      Uri.parse("http://${API.endpoint}/${API.name}/produtos/lista"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: Produto.toJsonList(produtos),
    );
    if (response.statusCode == 200) {
      return ;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido ou expirado.');
    } else {
      print(Produto.toJsonList(produtos));
      print(response.body);
      throw Exception('Erro inserindo produtos.');
    }
  }
}
