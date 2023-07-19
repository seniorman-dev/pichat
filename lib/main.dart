import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pichat/api/api.dart';
import 'package:pichat/main_page/controller/main_page_controller.dart';
import 'package:pichat/main_page/screen/main_page.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:pichat/user/settings/controller/profile_controller.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';






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
  //initial firebase
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
        home: MainPage()
      ),
    );
  }
}
