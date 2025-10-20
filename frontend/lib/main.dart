import 'package:flutter/material.dart';
import './pages/history/history_page.dart';
import './pages/cart/cart_page.dart';
import 'pages/home/home_page.dart';
import 'pages/splash/splash_page.dart';
import 'pages/onboarding/onboarding_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CampGear',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SplashPage(),
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/home': (context) => const Placeholder(), // ganti ke halaman utama kamu
      },
    );
  }
}
