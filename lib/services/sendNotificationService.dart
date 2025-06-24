import 'dart:convert';

import 'getServerKey.dart';
import 'package:http/http.dart' as http;

class sendNotificationService{
  static Future<void> sendNotificationUsingApi({
    required String? token,
    required String? title,
    required String? body,
    required Map<String, String>? data,
}) async{
    String serverKey = await GetServerKey().getServerKeyToken();
    String url = "https://fcm.googleapis.com/v1/projects/carehub-af7ec/messages:send";
    var header = <String, String>{
      "Content-type" : "application/json",
      "Authorization" : "Bearer $serverKey",
    };
    Map<String, dynamic> message={
      "message":{
        "token":token,
        "notification":{
          "body":body,
          "title":title
        },
        "data" : data
      }
    };
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: header,
      body: jsonEncode(message),
    );

    if(response.statusCode==200){
      print(response.body);
      print("Notification send");
    }else{
      print("Notification not send");
    }
  }
}