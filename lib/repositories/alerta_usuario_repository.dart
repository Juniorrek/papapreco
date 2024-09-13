import 'package:papapreco/model/alerta_usuario.dart';
import 'package:papapreco/rest/alerta_usuario_rest.dart';

class AlertaUsuarioRepository {
  final AlertaUsuarioRest api = AlertaUsuarioRest();

  Future<List<AlertaUsuario>> buscarPorUsuario(int usuarioId, String token) async {
    return await api.buscarPorUsuario(usuarioId, token);
  }

  Future<AlertaUsuario> inserir(AlertaUsuario notificacao, String token) async {
    return await api.inserir(notificacao, token);
  }

  Future<AlertaUsuario> alterar(AlertaUsuario notificacao, String token) async {
    return await api.alterar(notificacao, token);
  }

  Future<AlertaUsuario> remover(int id, String token) async {
    return await api.remover(id, token);
  }
}