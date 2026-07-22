import 'dart:async';
import 'package:http/http.dart' as http;

class NetworkClient {
  final http.Client _client;

  NetworkClient(this._client);

  Future<http.Response> get(String url) async {
    try {
      return await _client.get(Uri.parse(url)).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('The connection has timed out. Please try again.');
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
