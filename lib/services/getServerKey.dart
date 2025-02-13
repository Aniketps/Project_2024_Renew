import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class GetServerKey {
  Future<String> getServerKeyToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    const String apiUrl =
        "https://aniketapi.ancientcoders.in/notification_google_cloud_key";

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(jsonData),
        scopes,
      );
      final accessServerKey = client.credentials.accessToken.data;
      return accessServerKey;
    } else {
      throw Exception("Failed to fetch server key: ${response.statusCode}");
    }
  }
}
