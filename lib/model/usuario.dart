import 'dart:convert';

class Usuario {
  int? id;
  String nome;
  String email;
  String? senha;

  Usuario(this.id, this.nome, this.email, this.senha);
  Usuario.novo(this.nome, this.email, this.senha);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha
    };
  }
  static Usuario fromMap(Map<String, dynamic> map) {
    return Usuario(
      map['id'],
      map['nome'],
      map['email'],
      map['senha']
    );
  }

  static Usuario fromJson(String j) => Usuario.fromMap(jsonDecode(j));
  static List<Usuario> fromJsonList(String json) {
    final parsed = jsonDecode(json).cast<Map<String, dynamic>>();

    return parsed.map<Usuario>((map) => Usuario.fromMap(map)).toList();
  }
  
  String toJson() => jsonEncode(toMap());
}