import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/student_provider.dart';
import 'providers/tutor_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await Hive.initFlutter();
  await Hive.openBox(AppConstants.userBox);
  await Hive.openBox(AppConstants.cacheBox);

  runApp(const VocationalSkillsApp());
}

class VocationalSkillsApp extends StatelessWidget {
  const VocationalSkillsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => TutorProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            // ✅ Listen to auth state - auto rebuild on logout
            home: const SplashScreen(),
            // ✅ Reset all providers when user logs out
            builder: (context, child) {
              // When auth state changes to logged out, reset other providers
              if (!authProvider.isLoggedIn) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<StudentProvider>().reset();
                  context.read<TutorProvider>().reset();
                  context.read<AdminProvider>().reset();
                });
              }
              return child!;
            },
          );
        },
      ),
    );
  }
}
