import 'package:papapreco/util/configs.dart';

class API {
  //static const String endpoint = "localhost:8080";
  //static const String endpoint = "192.168.1.19:8080";
  static String endpoint = Configs.status == StatusConfig.cel ? "192.168.1.19:8080" : "10.0.2.2:8080";

  static const String name = "papaprecoapi";
}