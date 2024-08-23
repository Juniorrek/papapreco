import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:premiumprice/model/usuario.dart';
import 'package:premiumprice/rest/api.dart';

class AuthRest {
  Future<Map> signIn(String email, String senha) async {
    final http.Response response = await http.post(
      Uri.http(API.endpoint, '${API.name}/auth/signin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "email": email,
        "senha": senha
      }));

    if (response.statusCode == 200) {
      /*await context.read<AuthProvider>().login(token, usuario);

      await jwt_lib.storeToken(jsonDecode(response.body)['token']);
      await jwt_lib.storeUsuario(Usuario.fromMap(jsonDecode(response.body)['usuario']));*/

      return jsonDecode(response.body);
    } else {
      throw Exception('Erro fazendo login.');
    }
  }

  Future<Usuario> signUp(Usuario usuario) async {
    final http.Response response = await http.post(
      Uri.http(API.endpoint, '${API.name}/auth/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: usuario.toJson());

    if (response.statusCode == 200) {
      return Usuario.fromJson(response.body);
    } else {
      throw Exception('Erro cadastrando.');
    }
  }

  Future<String> recuperarSenhaGerarToken(String email) async {
    final http.Response response =
        await http.post(Uri.parse('http://${API.endpoint}/${API.name}/auth/redefinirSenha/gerarToken?email=$email'));

    if (response.statusCode == 200) {
      return "OK";
    } else {
      return response.body;
      //return response.body;
      //throw Exception('Erro gerar token.');
    }
  }

  Future<String> recuperarSenhaValidarToken(String email, String token) async {
    final http.Response response =
        await http.get(Uri.parse('http://${API.endpoint}/${API.name}/auth/redefinirSenha/validarToken?email=$email&token=$token'));

    if (response.statusCode == 200) {
      return "OK";
    } else {
      return response.body;
      //return response.body;
      //throw Exception('Erro gerar token.');
    }
  }

  Future<String> redefinirSenha(String email, String token, String novaSenha) async {
    final http.Response response =
        await http.post(Uri.parse('http://${API.endpoint}/${API.name}/auth/redefinirSenha'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, Object>{
        "token": token,
        "usuario": {
          "email": email
        },
        "novaSenha": novaSenha
      }));

    if (response.statusCode == 200) {
      return "OK";
    } else {
      return response.body;
      //return response.body;
      //throw Exception('Erro gerar token.');
    }
  }

}