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

  Future<List<Produto>> ranking(String palavra, double latitude, double longitude, double distancia, double precoMin, double precoMax) async {
    return await api.ranking(palavra, latitude, longitude, distancia, precoMin, precoMax);
  }

  Future<List<Produto>> historico(String nome, double latitude, double longitude) async {
    return await api.historico(nome, latitude, longitude);
  }

/* TODO: TROCAR PARA BUSCAR PRODUTO ATUAL NÃO PELO ID MAIS
  Future<List<Produto>> atual(String nome, double latitude, double longitude) async {
    return await api.historico(nome, latitude, longitude);
  }*/

  Future<List<Produto>> buscarPorUrlQrNFCeFazenda(String urlQr) async {
    return await api.buscarPorUrlQrNFCeFazenda(urlQr);
  }

  Future<Produto> inserir(Produto produto) async {
    return await api.inserir(produto);
  }
}