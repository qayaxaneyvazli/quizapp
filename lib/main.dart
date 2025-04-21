import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/providers/theme_mode_provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Important for SharedPreferences
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
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
      child: const HomeScreen(),  
    );
  }
}