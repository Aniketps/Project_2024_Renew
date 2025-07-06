import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class sendNotificationService {
  static Future<void> sendNotificationUsingApi({
    required String? token,
    required String? title,
    required String? body,
    required Map<String, String>? data,
  }) async {
    // ✅ Load service account JSON from assets using rootBundle
    final jsonString = await rootBundle.loadString('assets/service-account.json');
    final serviceAccount = jsonDecode(jsonString);

    final accountCredentials = ServiceAccountCredentials.fromJson(serviceAccount);

    // ✅ Required scope for Firebase Cloud Messaging
    const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    // ✅ Auth client using Google OAuth2
    final authClient = await clientViaServiceAccount(accountCredentials, scopes);

    const url = 'https://fcm.googleapis.com/v1/projects/carehub-af7ec/messages:send';

    final message = {
      "message": {
        "token": token,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": data,
      }
    };

    final response = await authClient.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('✅ Notification sent:');
      print(response.body);
    } else {
      print('❌ Notification not sent:');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
    }

    authClient.close();
  }
}
