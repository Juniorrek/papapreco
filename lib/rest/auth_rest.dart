import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:papapreco/model/usuario.dart';
import 'package:papapreco/rest/api.dart';

class AuthRest {
  Future<bool> atualizarFcmToken(Usuario usuario, String accessToken) async {
    String? firebaseToken = await FirebaseMessaging.instance.getToken();

    // Envie o token ao servidor
    final http.Response response = await http.put(
      Uri.http(API.endpoint, '${API.name}/usuarios/atualizarFcmToken'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, String>{
        "token": firebaseToken!,
        "idUsuario": usuario.id.toString(),
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<dynamic> signIn(String email, String senha) async {
    final http.Response response = await http.post(
      Uri.http(API.endpoint, '${API.name}/auth/login'),
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

      Map m = jsonDecode(response.body);

      bool r = await atualizarFcmToken(Usuario.fromMap(m["usuario"]), m["accessToken"]);

      return r ? m : response.body;
    } else {
      return response.body;
    }
  }


  Future<Map> signInGoogle(String idToken, String accessToken) async {
    final http.Response response = await http.post(
      Uri.http(API.endpoint, '${API.name}/auth/login/google'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "idToken": idToken
      }));

    if (response.statusCode == 200) {

      Map m = jsonDecode(response.body);

      bool r = await atualizarFcmToken(Usuario.fromMap(m["usuario"]), m["accessToken"]);

      if (r) return m;
      else throw Exception('Erro fazendo login via google');

    } else {
      throw Exception('Erro fazendo login via google.');
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
    }
  }

  Future<String> validarCodigoVerificacao(String email, String codigo) async {
    final http.Response response =
        await http.get(Uri.parse('http://${API.endpoint}/${API.name}/auth/validarCodigoVerificacao?email=$email&codigo=$codigo'));

    if (response.statusCode == 200) {
      return "OK";
    } else {
      return response.body;
    }
  }

  Future<String> verificarEmail(String email, String codigo) async {
    final http.Response response =
        await http.get(Uri.parse('http://${API.endpoint}/${API.name}/auth/verificarEmail?email=$email&codigo=$codigo'));

    if (response.statusCode == 200) {
      return "OK";
    } else {
      return response.body;
    }
  }

  Future<bool> enviarCodigoVerificacao(String email, String tipo) async {
    final http.Response response =
        await http.get(Uri.parse('http://${API.endpoint}/${API.name}/auth/enviarCodigoVerificacao?email=$email&tipo=$tipo'));

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<String> redefinirSenha(String email, String codigo, String novaSenha) async {
    final http.Response response =
        await http.post(Uri.parse('http://${API.endpoint}/${API.name}/auth/redefinirSenha'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, Object>{
        "codigo": codigo,
          "email": email,
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