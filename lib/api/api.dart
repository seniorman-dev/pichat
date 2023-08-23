import 'dart:convert';
import 'dart:io';
//import 'package:awesome_notifications/awesome_notifications.dart';
//import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pichat/constants/firebase_fcm_keys.dart';
import 'package:pichat/constants/one_signal_keys.dart';
import 'package:pichat/main.dart';
import 'package:pichat/main_page/screen/main_page.dart';
import 'package:pichat/theme/app_theme.dart';







class API {
  

  //REST API GET request to generate token from my heroku server for agora voice/video call

  //In the end, this is how your url should lok like if you want to see the token on your browser => https://agora-token-server-l2yj.onrender.com/rtc/MyChannel/1/uid/1/?expiry=300
  //Note: follow the agora implementation to create your token server
  
  String token = "";
  int tokenRole = 1; // use 1 for Host/Broadcaster, 2 for Subscriber/Audience
  String serverUrl = "https://agora-token-server-5ta9.onrender.com"; 
  // The base URL to your token server, for example "https://agora-token-service-production-92ff.up.railway.app"
  int tokenExpireTime = 45; // Expire time in Seconds.
  bool isTokenExpiring = false; // Set to true when the token is about to expire
  //final channelTextController = TextEditingController(text: ''); // To access the TextField
  //late RtcEngine agoraEngine;


  //call this when you want to join a voice call
  
  /*void setToken({required String newToken, required String channelName, required int uid, required RtcEngine agoraEngine}) async {
    token = newToken;

    if (isTokenExpiring) {
      // Renew the token
      agoraEngine.renewToken(token);
      isTokenExpiring = false;
      debugPrint("Token renewed");
    } 
    else {
      /// Join a channel.
      debugPrint("Token received, joining a channel...");
      await agoraEngine.joinChannel(
        token: token,
        channelId: channelName,
        //info: '',
        uid: uid, 
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
    }
  }

  //this function generates token when a user want to make a call or join a channel.
  Future<void> fetchToken({required int uid, required String channelName, required RtcEngine agoraEngine}) async {
    int tokenRole = 1; // use 1 for Host/Broadcaster, 2 for Subscriber/Audience
    
    // Prepare the Url
    String url = "https://agora-token-server-5ta9.onrender.com/rtc/jetify/1/uid/1/?expiry=45";  //'$serverUrl/rtc/$channelName/${tokenRole.toString()}/uid/${uid.toString()}?expiry=${tokenExpireTime.toString()}';

    // Send the request (GET REQUEST TO THE SERVER)
    final response = await http.get(Uri.parse(url));
    
    // Check the request response status
    if (response.statusCode == 200) {
        // If the server returns an OK response, then parse the JSON.
        Map<String, dynamic> json = jsonDecode(response.body);
        String newToken = json['rtcToken'];
        debugPrint('Token Received: $newToken');
        //return newToken;

        // Use the token to join a channel or renew an expiring token
        setToken(agoraEngine: agoraEngine, channelName: channelName, newToken: newToken, uid: uid,);
    } else {
        // If the server did not return an OK response,
        // then throw an exception.
        throw Exception(
          'Failed to fetch a token. Make sure that your server URL is valid'
        );
    }
  }*/




  Future initFLNP({required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin}) async{
    //FLNP Instance
    //FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    //FLNP component
    //This is used to define the initialization settings for iOS and android
    var initializationSettingsAndroid = const AndroidInitializationSettings('mip_map/ic_lancher.png');
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  }

  Future<void> showFLNP({var id = 0, required String title, required String body, var payload, required FlutterLocalNotificationsPlugin fln}) async{
    
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', //id
      'High Importance Notification', //title
      importance: Importance.high,
      enableLights: true,
      ledColor: Colors.white
    );
    
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channel.id, //'channel_id',
      channel.name, //'channel_name',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      //sound: RawResourceAndroidNotificationSound('notification')
    );


    var notification = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails()
    );
    
    await fln.show(id, title, body, notification);
  }

  //to be used for 'messages notification", 'friend request notifications e.t.c'
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
  
  //header for the end point
  final Map<String, String> headers = {
    'Authorization': 'key=$firebaseServerKeyFromTheConsole',
    'Content-type': 'application/json',
    'Accept': '/',
  };

  // notificationData or body for the end point
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
  
  //show notification with 'flutter_local_notification" plugin
  RemoteNotification? notification = const RemoteNotification();

  
  //flutter local notifications fuckkinngg worked.. finallyyyyy
  await showFLNP(title: title, body: content, fln: flutterLocalNotificationsPlugin);

  //Enable foreground Notifications for iOS
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

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
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
  
  flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: onSelectNotification);

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
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (message.notification != null) {
      debugPrint('Message also contained a notification: ${message.notification}'); //save to firebase
    }
    if(notification != null && android != null) {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', //id
        'High Importance Notification', //title
        importance: Importance.high
      );
        
      flutterLocalNotificationsPlugin.show(
        notification.hashCode, 
        notification.title, 
        notification.body, 
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id, 
            channel.name,
            //icon: 'launch_background'
          )
        )
      );
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