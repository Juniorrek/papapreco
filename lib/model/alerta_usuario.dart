import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:papapreco/model/usuario.dart';

class AlertaUsuario {
  int? id;
  String produto;
  Decimal preco;
  Usuario usuario;

  AlertaUsuario(this.id, this.produto, this.preco, this.usuario);
  AlertaUsuario.novo(this.produto, this.preco, this.usuario);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'produto': produto,
      'preco': preco,
      'usuario': usuario.toMap()
    };
  }
  static AlertaUsuario fromMap(Map<String, dynamic> map) {
    return AlertaUsuario(
      map['id'],
      map['produto'],
      Decimal.parse(map['preco'].toString()),
      Usuario.fromMap(map['usuario'])
    );
  }

  static AlertaUsuario fromJson(String j) => AlertaUsuario.fromMap(jsonDecode(j));
  static List<AlertaUsuario> fromJsonList(String json) {
    final parsed = jsonDecode(json).cast<Map<String, dynamic>>();

    return parsed.map<AlertaUsuario>((map) => AlertaUsuario.fromMap(map)).toList();
  }
  
  String toJson() => jsonEncode(toMap());
}