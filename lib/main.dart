import 'package:flutter/material.dart';
import 'app/home_screen.dart';

void main() {
  runApp(const SwimSuccessApp());
}

class SwimSuccessApp extends StatelessWidget {
  const SwimSuccessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swim Success',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121220),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF42A5F5),
          surface: const Color(0xFF1E1E2E),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
