import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/services/notifications_service.dart';
import 'package:quiz_app/providers/music/music_provider.dart';
import 'package:quiz_app/providers/theme_mode_provider.dart';
import 'package:quiz_app/providers/translations/translation_provider.dart';
import 'package:quiz_app/screens/login/login.dart';
import 'package:quiz_app/screens/login/register.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';
 import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
void main()async  {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: FirebaseOptions(
    apiKey: 'AIzaSyAKCdjAe-ZUyxdkSlGbdme2B_HvUvICYxk',
    appId: '1:325381610850:android:b2b1cd9144b4241fab203b',
    messagingSenderId: '325381610850',
    projectId: 'quiz-app-df0cd',
    storageBucket: 'quiz-app-df0cd.firebasestorage.app',
  )
  
);

  await FirebaseAppCheck.instance.activate(
    // For Android
    androidProvider: AndroidProvider.playIntegrity,
    // For iOS
    appleProvider: AppleProvider.appAttest,
    // For web
    webProvider: ReCaptchaV3Provider('your-recaptcha-site-key'),
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
 
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
     ref.watch(musicEnabledProvider);
     // Initialize translations when app starts
     ref.watch(translationProvider);
     
     WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsServiceProvider).initializeNotifications();
    });
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
          ScreenUtil.init(context); 
        return MaterialApp(
          
          debugShowCheckedModeBanner: false,
          title: 'Quiz App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: child,   
        );
      },
      child:  const LoginScreen(),  
    );
  }
}