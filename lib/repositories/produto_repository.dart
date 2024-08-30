import 'package:decimal/decimal.dart';
import 'package:papapreco/model/produto.dart';
import 'package:papapreco/model/usuario.dart';
import 'package:papapreco/rest/produto_rest.dart';

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

  Future<List<Produto>> ranking(String palavra, double latitude, double longitude, double distancia, Decimal precoMin, Decimal precoMax) async {
    return await api.ranking(palavra, latitude, longitude, distancia, precoMin, precoMax);
  }

  Future<List<Produto>> historico(String nome, double latitude, double longitude) async {
    return await api.historico(nome, latitude, longitude);
  }

/* TODO: TROCAR PARA BUSCAR PRODUTO ATUAL NÃO PELO ID MAIS
  Future<List<Produto>> atual(String nome, double latitude, double longitude) async {
    return await api.historico(nome, latitude, longitude);
  }*/

  Future<List<Produto>> buscarPorUrlQrNFCeFazenda(String urlQr, Usuario u) async {
    return await api.buscarPorUrlQrNFCeFazenda(urlQr, u);
  }

  Future<Produto> inserir(Produto produto, String token) async {
    return await api.inserir(produto, token);
  }

  Future<void> inserirLista(List<Produto> produtos, String token) async {
    return await api.inserirLista(produtos, token);
  }
}