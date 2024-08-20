import 'dart:convert';

class VotoUsuarioProduto {
  int? id;
  int produtoId;
  int usuarioId;
  bool voto;

  VotoUsuarioProduto(this.id, this.produtoId, this.usuarioId, this.voto);
  VotoUsuarioProduto.novo(this.produtoId, this.usuarioId, this.voto);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'produtoId': produtoId,
      'usuarioId': usuarioId,
      'voto': voto
    };
  }
  static VotoUsuarioProduto fromMap(Map<String, dynamic> map) {
    return VotoUsuarioProduto(
      map['id'],
      map['produtoId'],
      map['usuarioId'],
      map['voto']
    );
  }


  static List<VotoUsuarioProduto> fromMaps(List<Map<String, dynamic>> maps) {
    return List.generate(maps.length, (i) {
      return VotoUsuarioProduto.fromMap(maps[i]);
    });
  }

  static VotoUsuarioProduto fromJson(String j) => VotoUsuarioProduto.fromMap(jsonDecode(j));
  static List<VotoUsuarioProduto> fromJsonList(String json) {
    final parsed = jsonDecode(json).cast<Map<String, dynamic>>();

    return parsed.map<VotoUsuarioProduto>((map) => VotoUsuarioProduto.fromMap(map)).toList();
  }
  
  String toJson() => jsonEncode(toMap());
}