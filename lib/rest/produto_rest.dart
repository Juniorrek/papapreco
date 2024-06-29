import 'package:http/http.dart' as http;
import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/rest/api.dart';

class ProdutoRest {
  Future<List<Produto>> buscarPorNome(String nome) async {
    final http.Response response = await http.get(Uri.http(API.endpoint, "produtos/$nome"));

    if (response.statusCode == 200) {
      return Produto.fromJsonList(response.body);
    } else {
      throw Exception('Erro buscando os produtos por nome.');
    }
  }
}