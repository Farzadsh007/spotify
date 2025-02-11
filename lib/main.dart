import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spotify/bindings/home_binding.dart';
import 'package:spotify/utils/app_strings.dart';
import 'package:spotify/views/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        canvasColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: const TextStyle(color: Colors.white),
          bodyMedium: const TextStyle(color: Colors.white),
          bodySmall: const TextStyle(color: Colors.white),
          titleLarge:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleMedium:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleSmall: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1DB954),
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF121212),
          primary: const Color(0xFF1DB954),
          secondary: const Color(0xFF1DB954),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => HomeScreen(), binding: HomeBinding()),
      ],
    );
  }
}
