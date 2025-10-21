import 'package:campgear/pages/auth/sign_in_page.dart';
import 'package:campgear/pages/auth/sign_up_page.dart';
import 'package:campgear/pages/auth/welcome_page.dart';
import 'package:flutter/material.dart';
import './pages/history/history_page.dart';
import './pages/cart/cart_page.dart';
import 'pages/home/home_page.dart';
import 'pages/splash/splash_page.dart';
import 'pages/onboarding/onboarding_page.dart';
import 'layout/buttom_nav.dart';

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
      home: const BottomNav(),
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/welcome': (context) => const WelcomePage(),
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}
