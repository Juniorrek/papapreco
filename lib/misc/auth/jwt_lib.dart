import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:premiumprice/model/usuario.dart';

const storage = FlutterSecureStorage();

Future<void> storeToken(String token) async {
  await storage.write(key: 'token', value: token);
}

Future<String?> getToken() async {
  return await storage.read(key: 'token');
}

bool isTokenExpired(String token) {
  return JwtDecoder.isExpired(token);
}

Future<bool> logado() async {
  String? token = await getToken();

  if (token == null) return false;
  if (isTokenExpired(token)) return false;

  return true;
}

Future<void> storeUsuario(Usuario usuario) async {
  return await storage.write(key: 'usuario', value: usuario.toJson());
}

Future<Usuario?> usuarioLogado() async {
  bool l = await logado();
  
  if (!l) return null;

  String? userJson = await storage.read(key: 'usuario');

  if (userJson == null) return null;

  return Usuario.fromJson(userJson);
}

Future<void> logout() async {
  await storage.delete(key: 'token');
  await storage.delete(key: 'usuario');
}
