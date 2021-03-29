import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthToken {
  bool expiryCheck(String token) {
    return Jwt.isExpired(token);
  }

  Future<bool> refreshToken() async {
    final storage = new FlutterSecureStorage();
    String refreshToken = await storage.read(key: "refreshToken");

    await GlobalConfiguration().loadFromAsset("app_settings");
    var host = GlobalConfiguration().getValue("host");
    var port = GlobalConfiguration().getValue("authPort");
    var urlLocal = "https://" + host + ":" + port + '/token/';

    final response = await http.post(urlLocal,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"token": refreshToken}));

    if (response.statusCode == 200) {
      var newtoken = await jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('accessToken', newtoken["accessToken"]);
      print(newtoken["accessToken"] + " New token");
      return true;
    } else {
      throw Exception("Forbiden Action has been taken");
    }
  }

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken");
  }
}
