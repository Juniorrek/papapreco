import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:premiumprice/model/voto_usuario_produto.dart';
import 'package:premiumprice/rest/voto_usuario_produto_rest.dart';

class Produto {
  int? id;
  String nome;
  String? descricao;
  Decimal preco;
  double latitude;
  double longitude;
  String? localizacao;
  DateTime? dataInsercao;
  List<VotoUsuarioProduto>? votos;

  Produto(this.id, this.nome, this.descricao, this.preco, this.latitude, this.longitude, this.dataInsercao, this.votos);
  Produto.novo(this.nome, this.descricao, this.preco, this.latitude, this.longitude);

  bool usuarioJaVotou(int idUsuario) {
    return votos != null ? votos!.any((v) => v.usuarioId == idUsuario) : false;
  }
  bool usuarioJaVotouVoto(int idUsuario, bool voto) {
    return votos != null ? votos!.any((v) => v.usuarioId == idUsuario && v.voto == voto) : false;
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
      'latitude': latitude,
      'longitude': longitude,
      'dataInsercao': dataInsercao?.toIso8601String()
    };
  }
  static Produto fromMap(Map<String, dynamic> map) {
    return Produto(
      map['id'],
      map['nome'],
      map['descricao'],
      Decimal.parse(map['preco'].toString()),
      map['latitude'],
      map['longitude'],
      map['dataInsercao'] == null ? null : DateTime.parse(map['dataInsercao']),
      map['votos'] == null ? null : VotoUsuarioProduto.fromMaps(List<Map<String, dynamic>>.from(map['votos']))
    );
  }

  static Produto fromJson(String j) => Produto.fromMap(jsonDecode(j));
  static List<Produto> fromJsonList(String json) {
    final parsed = jsonDecode(json).cast<Map<String, dynamic>>();

    return parsed.map<Produto>((map) => Produto.fromMap(map)).toList();
  }
  
  String toJson() => jsonEncode(toMap());
}