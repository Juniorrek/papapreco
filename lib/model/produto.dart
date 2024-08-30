import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:papapreco/model/localizacao.dart';
import 'package:papapreco/model/usuario.dart';
import 'package:papapreco/model/voto_usuario_produto.dart';

class Produto {
  int? id;
  String nome;
  String? descricao;
  Decimal preco;
  Localizacao localizacao;
  DateTime dataInsercao;
  DateTime dataObservacao;
  List<VotoUsuarioProduto>? votos;
  Usuario? usuario;

  double? distanciaRelativa;
  String? dataRelativa;

  Produto(this.id, this.nome, this.descricao, this.preco, this.localizacao, this.dataInsercao, this.dataObservacao, this.votos, this.distanciaRelativa, this.dataRelativa, this.usuario);
  Produto.novo(this.nome, this.descricao, this.preco, this.localizacao, this.dataInsercao, this.dataObservacao, this.usuario);

  bool usuarioJaVotou(int idUsuario) {
    return votos != null ? votos!.any((v) => v.usuarioId == idUsuario) : false;
  }
  bool usuarioJaVotouVoto(int? idUsuario, bool voto) {
    return votos != null && idUsuario != null ? votos!.any((v) => v.usuarioId == idUsuario && v.voto == voto) : false;
  }
  int qntVotos(bool voto) {
    return votos != null ? votos!.where((v) => v.voto == voto).length : 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'localizacao': localizacao.toMap(),
      'dataInsercao': dataInsercao.toIso8601String(),
      'dataObservacao': dataObservacao.toIso8601String(),
      'usuario': usuario?.toMap()
    };
  }
  static Produto fromMap(Map<String, dynamic> map) {
    return Produto(
      map['id'],
      map['nome'],
      map['descricao'],
      Decimal.parse(map['preco'].toString()),
      Localizacao.fromMap(map['localizacao']),
      DateTime.parse(map['dataInsercao']),
      DateTime.parse(map['dataObservacao']),
      map['votos'] == null ? null : VotoUsuarioProduto.fromMaps(List<Map<String, dynamic>>.from(map['votos'])),
      map['distanciaRelativa'],
      map['dataRelativa'],
      Usuario.fromMap(map['usuario'])
    );
  }

  static Produto fromJson(String j) => Produto.fromMap(jsonDecode(j));
  static List<Produto> fromJsonList(String json) {
    final parsed = jsonDecode(json).cast<Map<String, dynamic>>();

    return parsed.map<Produto>((map) => Produto.fromMap(map)).toList();
  }
  
  String toJson() => jsonEncode(toMap());

  static String toJsonList(List<Produto> produtos) {
    final List<Map<String, dynamic>> produtoMapList = produtos.map((produto) => produto.toMap()).toList();
    return jsonEncode(produtoMapList);
  }
}