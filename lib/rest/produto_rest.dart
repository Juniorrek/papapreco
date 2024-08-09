import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/rest/api.dart';
import 'package:premiumprice/lib/map_lib.dart' as map_lib;

class ProdutoRest {
  Future<List<Produto>> buscarPorNome(String nome) async {
    final http.Response response =
        await http.get(Uri.http(API.endpoint, "produtos/$nome"));

    if (response.statusCode == 200) {
      return Produto.fromJsonList(response.body);
    } else {
      throw Exception('Erro buscando os produtos por nome.');
    }
  }

  Future<List<Produto>> buscarPorUrlQrNFCeFazenda(String urlQr) async {
    final http.Response response = await http.get(Uri.parse(urlQr));

    if (response.statusCode == 200) {
      var document = parse(response.body);

      //minerando localizacao
      var localizacao =
          document.getElementsByClassName("txtCenter").first.children[2].text;
      var geo = await map_lib.geocoding(localizacao);
      double lat = double.parse(geo[0]["lat"]);
      double lon = double.parse(geo[0]["lon"]);

      //minerando produtos
      var table = document.getElementById("tabResult");
      var trs = table?.children.first.children;

      List<Produto> produtos = [];
      RegExp exp = RegExp(r'[0-9]+,[0-9]+');
      if (trs != null) {
        for (final tr in trs) {
          produtos.add(Produto.novo(
              tr.getElementsByClassName("txtTit2").first.text,
              "",
              exp
                  .firstMatch(
                      tr.getElementsByClassName("RvlUnit").first.text)![0]!
                  .replaceAll(",", "."),
              lat,
              lon));
        }
      }

      //remove duplicados
      var seen = Set<String>();
      produtos = produtos.where((p) => seen.add(p.nome)).toList();

      return produtos;
    } else {
      throw Exception('Erro buscando os produtos do QR CODE.');
    }
  }
}
