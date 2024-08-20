import 'dart:convert';
import 'dart:ffi';

import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/model/usuario.dart';

class VotoUsuarioProduto {
  int? id;
  Produto produto;
  Usuario usuario;
  Bool voto;

  VotoUsuarioProduto(this.id, this.produto, this.usuario, this.voto);
  VotoUsuarioProduto.novo(this.produto, this.usuario, this.voto);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'produto': produto,
      'usuario': usuario,
      'voto': voto
    };
  }
  static VotoUsuarioProduto fromMap(Map<String, dynamic> map) {
    return VotoUsuarioProduto(
      map['id'],
      map['produto'],
      map['usuario'],
      map['voto']
    );
  }

  static VotoUsuarioProduto fromJson(String j) => VotoUsuarioProduto.fromMap(jsonDecode(j));
  static List<VotoUsuarioProduto> fromJsonList(String json) {
    final parsed = jsonDecode(json).cast<Map<String, dynamic>>();

    return parsed.map<VotoUsuarioProduto>((map) => VotoUsuarioProduto.fromMap(map)).toList();
  }
  
  String toJson() => jsonEncode(toMap());
}