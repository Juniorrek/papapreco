import 'dart:convert';

class Produto {
  int? id;
  String nome;
  String descricao;
  String preco;
  double latitude;
  double longitude;
  String? localizacao;

  Produto(this.id, this.nome, this.descricao, this.preco, this.latitude, this.longitude);
  Produto.novo(this.nome, this.descricao, this.preco, this.latitude, this.longitude);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'latitude': latitude,
      'longitude': longitude
    };
  }
  static Produto fromMap(Map<String, dynamic> map) {
    return Produto(
      map['id'],
      map['nome'],
      map['descricao'],
      map['preco'],
      map['latitude'],
      map['longitude'],
    );
  }

  static Produto fromJson(String j) => Produto.fromMap(jsonDecode(j));
  static List<Produto> fromJsonList(String json) {
    final parsed = jsonDecode(json).cast<Map<String, dynamic>>();

    return parsed.map<Produto>((map) => Produto.fromMap(map)).toList();
  }
  
  String toJson() => jsonEncode(toMap());
}