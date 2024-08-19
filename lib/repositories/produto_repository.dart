import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/rest/produto_rest.dart';

class ProdutoRepository {
  final ProdutoRest api = ProdutoRest();

  Future<Produto> buscarPorId(int id) async {
    return await api.buscarPorId(id);
  }

  Future<List<Produto>> buscarPorNome(String nome) async {
    return await api.buscarPorNome(nome);
  }

  Future<List<Produto>> filtrar(String nome, double latitude, double longitude, double distancia, double precoMin, double precoMax) async {
    return await api.filtrar(nome, latitude, longitude, distancia, precoMin, precoMax);
  }

  Future<List<Produto>> buscarPorUrlQrNFCeFazenda(String urlQr) async {
    return await api.buscarPorUrlQrNFCeFazenda(urlQr);
  }
}