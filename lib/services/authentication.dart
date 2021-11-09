// Token Authentication Services

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chat_app/services/secure_storage.dart';
import 'package:chat_app/constants.dart';

const serverURL = '$kServerBaseURL/api-token-auth/';

class Authentication {
  Future<void> authenticateUser(String username, String password) async {
    http.Response response = await http.post(
      Uri.parse(serverURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      String jsonData = response.body;
      Map data = jsonDecode(jsonData);
      final SecureStorage secureStorage = SecureStorage();
      await secureStorage.writeSecureData('token', data['token']);
    } else {
      throw Exception('Wrong credentials');
    }
  }
}
