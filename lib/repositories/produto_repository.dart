import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/rest/produto_rest.dart';

class ProdutoRepository {
  final ProdutoRest api = ProdutoRest();

  Future<List<Produto>> buscarPorNome(String nome) async {
    return await api.buscarPorNome(nome);
  }

  Future<List<Produto>> buscarPorUrlQrNFCeFazenda(String urlQr) async {
    return await api.buscarPorUrlQrNFCeFazenda(urlQr);
  }
}