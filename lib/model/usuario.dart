import 'dart:convert';
import 'dart:ffi';

import 'package:papapreco/model/localizacao.dart';

class Usuario {
  int? id;
  String nome;
  String email;
  String? senha;
  Localizacao? localizacao;
  bool verificado;

  Usuario(this.id, this.nome, this.email, this.senha, this.localizacao, this.verificado);
  Usuario.novo(this.nome, this.email, this.senha, this.verificado);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'localizacao': localizacao?.toMap(),
      'verificado': verificado
    };
  }
  static Usuario fromMap(Map<String, dynamic> map) {
    return Usuario(
      map['id'],
      map['nome'],
      map['email'],
      map['senha'],
      map['localizacao'] == null ? map['localizacao'] : Localizacao.fromMap(map['localizacao']),
      map['verificado']
    );
  }

  static Usuario fromJson(String j) => Usuario.fromMap(jsonDecode(j));
  static List<Usuario> fromJsonList(String json) {
    final parsed = jsonDecode(json).cast<Map<String, dynamic>>();

    return parsed.map<Usuario>((map) => Usuario.fromMap(map)).toList();
  }
  
  String toJson() => jsonEncode(toMap());
}