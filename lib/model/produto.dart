import 'dart:convert';

class Produto {
  int id;
  String nome;
  String descricao;
  String preco;

  Produto(this.id, this.nome, this.descricao, this.preco);

  static Produto fromMap(Map<String, dynamic> map) {
    return Produto(
      map['id'],
      map['nome'],
      map['descricao'],
      map['preco'],
    );
  }

  static List<Produto> fromJsonList(String json) {
    final parsed = jsonDecode(json).cast<Map<String, dynamic>>();

    return parsed.map<Produto>((map) => Produto.fromMap(map)).toList();
  }
}