import 'dart:convert';

import 'package:decimal/decimal.dart';

class Produto {
  int? id;
  String nome;
  String? descricao;
  Decimal preco;
  double latitude;
  double longitude;
  String? localizacao;
  DateTime? dataInsercao;

  Produto(this.id, this.nome, this.descricao, this.preco, this.latitude, this.longitude, this.dataInsercao);
  Produto.novo(this.nome, this.descricao, this.preco, this.latitude, this.longitude);

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
      DateTime.parse(map['dataInsercao'])
    );
  }

  static Produto fromJson(String j) => Produto.fromMap(jsonDecode(j));
  static List<Produto> fromJsonList(String json) {
    final parsed = jsonDecode(json).cast<Map<String, dynamic>>();

    return parsed.map<Produto>((map) => Produto.fromMap(map)).toList();
  }
  
  String toJson() => jsonEncode(toMap());
}