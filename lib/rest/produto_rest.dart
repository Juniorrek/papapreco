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
import 'package:papapreco/util/configs.dart';

class ProdutoRest {
  Future<Produto> buscarPorId(int id) async {
    final http.Response response = await http
        .get(Uri.parse("http://${API.endpoint}/${API.name}/produtos/$id"));

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

  Future<List<Produto>> filtrar(String nome, double latitude, double longitude,
      double distancia, double precoMin, double precoMax) async {
    final http.Response response = await http.get(Uri.parse(
        "http://${API.endpoint}/produtos/filtrar?nome=$nome&latitude=$latitude&longitude=$longitude&distancia=$distancia&precoMin=$precoMin&precoMax=$precoMax"));

    if (response.statusCode == 200) {
      List<Produto> produtos = Produto.fromJsonList(response.body);

      return produtos;
    } else {
      throw Exception('Erro filtrando os produtos.');
    }
  }

  Future<List<Produto>> ranking(
      String palavra,
      double latitude,
      double longitude,
      double distancia,
      Decimal precoMin,
      Decimal precoMax) async {
    final http.Response response = await http.get(Uri.parse(
        "http://${API.endpoint}/${API.name}/produtos/ranking?palavra=$palavra&latitude=$latitude&longitude=$longitude&distancia=$distancia&precoMin=$precoMin&precoMax=$precoMax"));

    if (response.statusCode == 200) {
      List<Produto> produtos = Produto.fromJsonList(response.body);

      return produtos;
    } else {
      throw Exception('Erro ranking os produtos.');
    }
  }

  Future<List<Produto>> historico(
      String nome, double latitude, double longitude) async {
    final http.Response response = await http.get(Uri.parse(
        "http://${API.endpoint}/${API.name}/produtos/historico?nome=$nome&latitude=$latitude&longitude=$longitude"));

    if (response.statusCode == 200) {
      List<Produto> produtos = Produto.fromJsonList(response.body);

      return produtos;
    } else {
      throw Exception('Erro historico os produtos.');
    }
  }

  Future<List<Produto>> buscarPorUrlQrNFCeFazenda(
      String urlQr, Usuario u) async {
    final http.Response response = await http.get(Uri.parse(urlQr));

    if (Configs.status == StatusConfig.cel) {
      print(response.request?.url.toString());
    }

    if (response.statusCode == 200) {
      var document = parse(response.body);

      //minerando localizacao
      var localizacao =
          document.getElementsByClassName("txtCenter").first.children[2].text;

      //TENTATIVA 1 LOCALIZACAO
      var geo = await map_lib.geocoding(localizacao);

      //TENTATIVA 2 LOCALIZACAO
      if (geo == null || geo.length == 0) {
        // Remover quebras de linha e espaços desnecessários
        String enderecoFormatado =
            localizacao.replaceAll(RegExp(r'\s+'), ' ').trim();

        // Remover possíveis vírgulas extras
        enderecoFormatado =
            enderecoFormatado.replaceAll(RegExp(r',\s*,+'), ',');
        geo = await map_lib.geocoding(enderecoFormatado);
      }


      //TENTATIVA 3 LOCALIZACAO cnpj
      if (geo == null || geo.length == 0) {
        String cnpj = document.getElementsByClassName("txtCenter").first.children[1].text.replaceAll(RegExp(r'\D'), '');
        
        Map<String, dynamic> dadosReceita = await buscarPorCnpj(cnpj);

        String endereco = construirEnderecoCnpjReceita1(dadosReceita);
        geo = await map_lib.geocoding(endereco);
      }

      //TENTATIVA 4 LOCALIZACAO cnpj
      /*if (geo == null || geo.length == 0) {
        String cnpj = document.getElementsByClassName("txtCenter").first.children[1].text.replaceAll(RegExp(r'\D'), '');
        
        Map<String, dynamic> dadosReceita = await buscarPorCnpj(cnpj);

        String endereco = construirEnderecoCnpjReceita2(dadosReceita);
        geo = await map_lib.geocoding(endereco);
      }*/

      double? lat = null;
      double? lon = null;
      String? localizacaoString = null;
      if (geo != null && geo.length > 0) {
        lat = double.parse(geo[0]["lat"]);
        lon = double.parse(geo[0]["lon"]);
        localizacaoString = await map_lib.reverseGeocodingShop(lat, lon);
      }

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
                  .replaceAll(",", ".")),
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

  String construirEnderecoCnpjReceita1(Map<String, dynamic> dados) {
  final logradouro = dados['logradouro'] ?? '';
  final numero = dados['numero'] ?? '';
  final complemento = dados['complemento'] != null ? ', ${dados['complemento']}' : '';
  final bairro = dados['bairro'] ?? '';
  final municipio = dados['municipio'] ?? '';
  final uf = dados['uf'] ?? '';
  final cep = dados['cep'] ?? '';

  return '$logradouro, $numero, $complemento, $bairro, $municipio, $uf, $cep';
}

  String construirEnderecoCnpjReceita2(Map<String, dynamic> dados) {
  final logradouro = dados['logradouro'] ?? '';
  final numero = dados['numero'] ?? '';
  final municipio = dados['municipio'] ?? '';
  final uf = dados['uf'] ?? '';

  return '$logradouro, $numero, $municipio, $uf';
}

  Future<Map<String, dynamic>> buscarPorCnpj(String cnpj) async {
  // Formata o CNPJ removendo caracteres especiais
  String cnpjFormatado = cnpj.replaceAll(RegExp(r'\D'), '');

  // URL da API do ReceitaWS
  String url = 'https://www.receitaws.com.br/v1/cnpj/$cnpjFormatado';

  // Faz a requisição GET para a API
  final response = await http.get(Uri.parse(url));

  // Verifica se a requisição foi bem-sucedida
  if (response.statusCode == 200) {
    // Converte a resposta JSON para um mapa (Map<String, dynamic>)
    return json.decode(response.body);
  } else {
    // Lança uma exceção em caso de erro
    throw Exception('Erro ao buscar o CNPJ');
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
      return;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token inválido ou expirado.');
    } else {
      throw Exception('Erro inserindo produtos.');
    }
  }
}
