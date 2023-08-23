import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pichat/api/api.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/auth/screen/splash_screen.dart';
import 'package:pichat/auth/screen/splash_screen_2.dart';
import 'package:pichat/main_page/controller/main_page_controller.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:pichat/user/feeds/controller/feeds_controller.dart';
import 'package:pichat/user/settings/controller/profile_controller.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'user/group_chat/controller/group_chat_controller.dart';
import 'user/notifications/controller/notifications_controller.dart';
import 'utils/error_loader.dart';
import 'utils/loader.dart';





//flutter local notifications fuckkinngg worked.. finallyyyyy
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();



//Top level non-anonymous function for FCM push notifications for background mode
Future<void> backgroundHandler(RemoteMessage message) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', //id
    'High Importance Notification', //title
    importance: Importance.high
  );
  debugPrint('Handling a background message ${message.messageId}');

  //added this to catch the back ground push notification and display it in foreground cause user may be using the app
  flutterLocalNotificationsPlugin.show(
    message.data.hashCode, 
    message.data['title'], 
    message.data['body'], 
    NotificationDetails(
      android: AndroidNotificationDetails(channel.id, channel.name,)
    )
  );

}



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: AppTheme().whiteColor,
      statusBarColor: AppTheme().whiteColor,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  //initialize get_storage
  await GetStorage.init();
  //initialize firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

  //initialize firebase cloud messaging
  API().initFCM(backgroundHandler: backgroundHandler);


  //run multi provider here to add all your providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MainPageController>(
          create: (_) => MainPageController(),
        ),
        ChangeNotifierProvider<ProfileController>(
          create: (_) => ProfileController(),
        ),
        ChangeNotifierProvider<ChatServiceController>(
          create: (_) => ChatServiceController(),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController()
        ),
        ChangeNotifierProvider<FeedsController>(
          create: (_) => FeedsController()
        ),
        ChangeNotifierProvider<NotificationsController>(
          create: (_) => NotificationsController()
        ),
        ChangeNotifierProvider<GroupChatController>(
          create: (_) => GroupChatController()
        )
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> { 
  // This widget is the root of your application.

  FirebaseMessaging fcm = FirebaseMessaging.instance;
  //FirebaseMessaging fc = FirebaseMessaging();

  //get FCM Token
  getToken() async{
    String? token = await fcm.getToken();
    debugPrint('token for foreground: $token');
    return token;
  }

  String? notifTitle;
  String? notifBody;

  @override
  void initState() {
    // TODO: implement initState
    API().initFLNP(flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);

    //did this specifically to show fcm push notifications when the app is in foreground mode
    FirebaseMessaging.onMessage.listen((RemoteMessage message){
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      
      if(notification != null && android != null) {
        
        FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'high_importance_channel', //id
          'High Importance Notification', //title
          importance: Importance.high
        );

        AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
          channel.id, //'channel_id',
          channel.name, //'channel_name',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          //sound: RawResourceAndroidNotificationSound('notification')
        );
        
        flutterLocalNotificationsPlugin.show(
          notification.hashCode, 
          notification.title, 
          notification.body, 
          NotificationDetails(
            android: androidNotificationDetails,
            iOS: DarwinNotificationDetails()
          )
        );
      }
    });

    getToken();
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: (_, child) {
        return child!;
      },
      child: GetMaterialApp(
        transitionDuration: Duration(milliseconds: 100),
        debugShowCheckedModeBanner: false,
        home: FirebaseCheck()  //MainPage()
      ),
    );
  }
  
}


class FirebaseCheck extends StatelessWidget {
  const FirebaseCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authController = Provider.of<AuthController>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme().whiteColor,
        body: StreamBuilder<User?>(
          stream: authController.firebase.authStateChanges(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            else if(snapshot.connectionState == ConnectionState.active) {
              if(snapshot.data == null) {
                return const SplashePage1();
              }
              else {
                return const SplashePage2();
              }
            }
            else {
              return const ErrorLoader();
            }
          }
        )
      ),
    );
  }
}