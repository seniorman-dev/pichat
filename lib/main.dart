import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pichat/api/api.dart';
import 'package:pichat/auth/controller/auth_controller.dart';
import 'package:pichat/auth/screen/register_screen.dart';
import 'package:pichat/auth/screen/splash_screen.dart';
import 'package:pichat/auth/screen/splash_screen_2.dart';
import 'package:pichat/main_page/controller/main_page_controller.dart';
import 'package:pichat/main_page/screen/main_page.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/chat/controller/chat_service_controller.dart';
import 'package:pichat/user/settings/controller/profile_controller.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'utils/error_loader.dart';
import 'utils/loader.dart';








//Top level non-anonymous function for FCM push notifications for background mode
Future<void> backgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message ${message.messageId}');
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
        )
      ],
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
              return Loader();
            }
            else if(snapshot.connectionState == ConnectionState.active) {
              if(snapshot.data == null) {
                return SplashePage1();
              }
              else {
                return SplashePage2();
              }
            }
            else {
              return ErrorLoader();
            }
          }
        )
      ),
    );
  }
}