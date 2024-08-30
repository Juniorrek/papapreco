import 'package:papapreco/model/voto_usuario_produto.dart';
import 'package:papapreco/rest/voto_usuario_produto_rest.dart';

class VotoUsuarioProdutoRepository {
  final VotoUsuarioProdutoRest api = VotoUsuarioProdutoRest();

  Future<VotoUsuarioProduto> buscarPorId(int id) async {
    return await api.buscarPorId(id);
  }

  Future<VotoUsuarioProduto> votar(int produtoId, int usuarioId, bool voto) async {
    return await api.votar(produtoId, usuarioId, voto);
  }

  Future<VotoUsuarioProduto> mudarVoto(int produtoId, int usuarioId, bool novoVoto) async {
    return await api.mudarVoto(produtoId, usuarioId, novoVoto);
  }
}