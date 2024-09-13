import 'dart:convert';

class Localizacao {
  int? id;
  double? latitude;
  double? longitude;
  String? descricao;

  Localizacao(this.id, this.latitude, this.longitude, this.descricao);
  Localizacao.novo(this.latitude, this.longitude, this.descricao);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'descricao': descricao
    };
  }
  static Localizacao fromMap(Map<String, dynamic> map) {
    return Localizacao(
      map['id'],
      map['latitude'],
      map['longitude'],
      map['descricao'],
    );
  }

  static Localizacao fromJson(String j) => Localizacao.fromMap(jsonDecode(j));
  static List<Localizacao> fromJsonList(String json) {
    final parsed = jsonDecode(json).cast<Map<String, dynamic>>();

    return parsed.map<Localizacao>((map) => Localizacao.fromMap(map)).toList();
  }
  
  String toJson() => jsonEncode(toMap());
}