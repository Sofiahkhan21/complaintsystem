import 'package:complaintsystem/provider/provider.dart';
import 'package:complaintsystem/screens/chat/testing.dart';
import 'package:complaintsystem/splash.dart';
import 'package:complaintsystem/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
 
  FirebaseMessaging.onBackgroundMessage(NotifcationHelper.background);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: ChangeNotifierProvider(
        create: (BuildContext context) => ComplaintProvider(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Complaint App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          //home: AuthScreen(),
          home: SplashScreen(),
        ),
      ),
    );
  }
}
