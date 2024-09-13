import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:papapreco/misc/auth/jwt_lib.dart' as jwt_lib;
import 'package:papapreco/model/localizacao.dart';
import 'package:papapreco/model/usuario.dart';


class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _token;
  Usuario? _usuario;

  String? get token => _token;
  Usuario? get usuario => _usuario;

  bool get isLoggedIn => _token != null && _usuario != null;

  Future<void> login(String token, Usuario usuario) async {
    _token = token;
    _usuario = usuario;

    //jwt_lib.storeToken(token)

    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'usuario', value: usuario.toJson());

    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _usuario = null;

    await _storage.delete(key: 'token');
    await _storage.delete(key: 'usuario');

    notifyListeners();
  }

  Future<void> loadUser() async {
    String? token = await _storage.read(key: 'token');
    String? usuarioJson = await _storage.read(key: 'usuario');

    if (token != null && usuarioJson != null && !JwtDecoder.isExpired(token)) {
      _token = token;
      _usuario = Usuario.fromJson(usuarioJson);
    } else {
      _token = null;
      _usuario = null;
    }

    notifyListeners();
  }

  Future<void> setUsuario(Usuario usuario) async {
    _usuario = usuario;

    await _storage.write(key: 'usuario', value: usuario.toJson());

    notifyListeners();
  }

  /*Future<void> setLocalizacao(Localizacao localizacao) async {
    if (usuario != null) {
      usuario!.localizacao = localizacao;

      await _storage.write(key: 'usuario', value: usuario!.toJson());

      notifyListeners();
    }
  }*/
}
