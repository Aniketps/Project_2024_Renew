import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:carehub/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationService{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async{
    NotificationSettings setting = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if(setting.authorizationStatus == AuthorizationStatus.authorized){
      print("User grand permission");
    }else if (setting.authorizationStatus == AuthorizationStatus.provisional){
      print("User provisional permission");
    }else{
      Fluttertoast.showToast(msg: "Notification premission denied");
      Fluttertoast.showToast(msg: "Please allow notification to receive updates");

      Future.delayed(Duration(seconds: 3), (){
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      });
    }
  }

  Future<String?> getDeviceToken() async{
    NotificationSettings settings = await messaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
    );

    String? token = await messaging.getToken();
    return token;
  }

  void initLocalNotifications(BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
    const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
          // handle interaction when app is active for android
          handleMessage(context, message);
        });
  }

  void firebaseInit(BuildContext context){
    FirebaseMessaging.onMessage.listen((message){
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      if(kDebugMode){
        print("notification title : ${notification!.title}");
        print("notification body : ${notification.body}");
      }
      if(Platform.isAndroid){
        initLocalNotifications(context, message);
        showNotification(message);
      }
    });
  }

  Future<void> setupInteractMessage(BuildContext context) async{
    FirebaseMessaging.onMessageOpenedApp.listen((message){
      handleMessage(context, message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message){
      if(message!=null && message.data.isNotEmpty){
        handleMessage(context, message);
      }
    });
  }

  Future<void> showNotification(RemoteMessage message)async{
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        message.notification!.android!.channelId.toString(),
        message.notification!.android!.channelId.toString(),
        importance: Importance.max,
        showBadge: true,
        playSound: true
    );
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString(),
      channelDescription: "Channel Descripation",
      importance: Importance.high,
      priority: Priority.high,
      sound: channel.sound,
      playSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    Future.delayed(Duration.zero, (){
      // Generate a unique notification ID based on the current timestamp in seconds
      int uniqueId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Show the notification with a unique ID
      _flutterLocalNotificationsPlugin.show(
          uniqueId, // Unique notification ID
          message.notification!.title.toString(), // Notification title
          message.notification!.body.toString(),  // Notification body
          notificationDetails,  // Notification details (icon, sound, etc.)
          payload: "my_data"    // Additional payload data
      );
    });
  }

  Future androidForgroundMessage() async{
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> handleMessage(BuildContext context, RemoteMessage message) async{
    Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(),));
  }

}