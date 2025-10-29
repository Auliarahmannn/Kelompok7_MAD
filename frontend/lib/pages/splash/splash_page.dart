import 'package:campgear/pages/admin/dashboard_page.dart';
import 'package:flutter/material.dart';
import '../onboarding/onboarding_page.dart';
import 'package:campgear/layout/buttom_nav.dart';
import 'package:campgear/services/auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;

  final String _appName = 'CampGear';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Logo jatuh seperti bola memantul
    _logoAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    );

    _controller.forward();

    // Navigate setelah delay
    Future.delayed(const Duration(seconds: 5), _checkLoginStatus);
  }

  Future<void> _checkLoginStatus() async {
    final token = await AuthService.getToken();
    final role = await AuthService.getRole();

    if (!mounted) return;

    if (token != null && role != null) {
      if (role == 'admin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BottomNav()),
          (route) => false,
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D755E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - _logoAnimation.value) * -200),
                  child: Image.asset('assets/images/logo.png', width: 120),
                );
              },
            ),
            const SizedBox(height: 20),
            // Teks ketikan otomatis
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: _appName.length),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                String text = _appName.substring(0, value);
                return Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
