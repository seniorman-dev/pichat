import 'dart:convert';
import 'dart:io';
//import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pichat/constants/firebase_fcm_keys.dart';
import 'package:pichat/constants/one_signal_keys.dart';
import 'package:pichat/main_page/screen/main_page.dart';







class API {

  Future<void> sendPushNotificationWithFirebaseAPI({required String receiverFCMToken, required String title, required String content}) async {
  //TODO: make the notification display in foreground
  
  //FCM Instance
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  //grant permission for Android (Android is always automatic)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  debugPrint('User granted permission: ${settings.authorizationStatus}');

  //grant permission for iOS
  if (Platform.isIOS) {
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }
  
  //header
  final Map<String, String> headers = {
    'Authorization': 'key=$firebaseServerKeyFromTheConsole',
    'Content-type': 'application/json',
    'Accept': '/',
  };

  // notificationData or body
  final Map<String, dynamic> notificationData = {
    "to": receiverFCMToken,
    "priority": "high",
    "notification": {
      "title": title,
      "body":content,
      "sound": "default"
    },
    "data": {
      "title": title,
      "body": content,
      "type": "chat",
      "click_action": "FLUTTER_NOTIFICATION_CLICK"
    // Add other optional parameters for customizing your notification
    }
  };

  //send a POST request
  final http.Response response = await http.post(
    Uri.parse(apiUrl),
    headers: headers,
    body: json.encode(notificationData),  //notificationData
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully');
  } else {
    print('Error sending notification: ${response.statusCode}\n${response.body}');
  }

}



Future<void> sendPushNotificationWithOneSignalAPI({required String receiverFCMToken, required String title, required String content}) async {
  //final String oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID';
  //final String oneSignalApiKey = 'YOUR_ONESIGNAL_API_KEY';
  //final String apiUrl = 'https://onesignal.com/api/v1/notifications';


  final Map<String, dynamic> notificationData = {
    'app_id': oneSignalAppId,
    'contents': {'en': content},
    'headings': {'en': title},
    'include_player_ids': [receiverFCMToken],
    // Add other optional parameters for customizing your notification
    "to": receiverFCMToken,
    "data": {
      "title": title,
      "body": content,
      "type": "chat",
      "click_action": "FLUTTER_NOTIFICATION_CLICK"
    // Add other optional parameters for customizing your notification
    }
  };

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    //'Authorization': 'Baisc $oneSignalRESTAPIKey',
    //added this below
    'Authorization': 'key=$firebaseServerKeyFromTheConsole',
  };
  //send a POST request
  final http.Response response = await http.post(
    Uri.parse(apiUrl),
    headers: headers,
    body: json.encode(notificationData),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully');
  } else {
    print('Error sending notification: ${response.statusCode}\n${response.body}');
  }
}



Future<void> initFCM({required Future<void> Function(RemoteMessage) backgroundHandler}) async {
  ///////////////FCM  SET UP
  
  //FCM Instance
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  //FLNP Instance
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //FLNP component
  //This is used to define the initialization settings for iOS and android
  var initializationSettingsAndroid = const AndroidInitializationSettings('@drawable/ic_stat_ic_notification');
  var initializationSettingsIOS = const DarwinInitializationSettings();
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  // This handles routing to a specific page when there's a click event on the notification when the app is in foreground mode
  void onSelectNotification(NotificationResponse notificationResponse) async {
    debugPrint(notificationResponse.payload);
    var payloadData = jsonDecode(notificationResponse.payload!);
    if (payloadData["type"] == "home") {
      Get.to(() => const MainPage());
    }
  }
  
  _flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: onSelectNotification);

  //Get Unique FCM DEVICE TOKEN
  String? token = await messaging.getToken();
  debugPrint('My Device Token: $token'); //save to firebase

  //grant permission for Android (Android is always automatic)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  debugPrint('User granted permission: ${settings.authorizationStatus}');

  //grant permission for iOS
  if (Platform.isIOS) {
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  // Listneing to the foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}'); //save to firebase

    if (message.notification != null) {
      debugPrint('Message also contained a notification: ${message.notification}'); //save to firebase
    }
  });
  //Enable foreground Notifications for iOS
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  //TODO: USE FLUTTER LOCAL NOTIFICATIONS TO DISPLAY FOREGROUND NOTIFICATIONS

  // Listening to the background messages

  // Enable Background Notification to retrieve any message which caused the application to open from a terminated state
  RemoteMessage? initialMessage = await messaging.getInitialMessage();

 // This handles routing to a secific page when there's a click event on the notification
  void handleMessage(RemoteMessage message) {
    //specify message data types here
    if (message.data['type'] == 'home') {
      Get.to(() => const MainPage());
    }
  }

  if (initialMessage != null) {
    handleMessage(initialMessage);
  }

  // This handles background notifications when the app is not terminated
  FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

  //This handles background notifications when the app is terminated
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  //////////////////////////////////////////////

}

}