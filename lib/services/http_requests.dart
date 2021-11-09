// Class with HTTP requests to Back

import 'package:chat_app/services/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:chat_app/constants.dart';

class HttpRequestBack {
  Future getSupplierScreenData() async {
    String token = await SecureStorage().readSecureData('token');
    final response = http.get(
      Uri.parse('$kServerBaseURL/api/getsuppliers'),
      // Send authorization headers to the backend.
      headers: {
        'Authorization': 'Token $token',
      },
    );
    return response;
  }
}
