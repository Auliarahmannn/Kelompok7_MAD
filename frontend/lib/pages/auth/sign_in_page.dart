import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:campgear/layout/buttom_nav.dart';
import 'package:campgear/services/auth_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool loading = false;

  String? emailError;
  String? passwordError;
  String? generalError;

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      emailError = null;
      passwordError = null;
      generalError = null;
    });

    bool hasError = false;

    if (email.isEmpty) {
      emailError = 'Email tidak boleh kosong';
      hasError = true;
    } else if (!email.contains('@')) {
      emailError = 'Email tidak valid';
      hasError = true;
    }

    if (password.isEmpty) {
      passwordError = 'Password tidak boleh kosong';
      hasError = true;
    } else if (password.length < 8) {
      passwordError = 'Password minimal 8 karakter';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => loading = true);

    try {
      final result = await AuthService.login(email, password);

      if (result['status'] == 'success') {
        final role = result['role'];

        if (!mounted) return;

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BottomNav()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BottomNav()),
          );
        }
      } else {
        setState(() => generalError = result['message'] ?? 'Login gagal');
      }
    } catch (e) {
      setState(() => generalError = 'Terjadi kesalahan: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF587C4E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Image.asset('assets/images/loginlogo.png', height: 170),
                  const SizedBox(height: 70),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Email"),
                          TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              hintText: "Masukan Email Anda",
                            ),
                          ),
                          if (emailError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Text(
                                emailError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),

                          const Text("Password"),
                          TextField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            decoration: InputDecoration(
                              hintText: "Masukan Password Anda",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          if (passwordError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Text(
                                passwordError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Lupa Password?",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (generalError != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                generalError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: const Color(0xFFD3B073),
                            ),
                            onPressed: loading ? null : _login,
                            child: loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Sign In",
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                          const SizedBox(height: 20),

                          const Center(child: Text("OR")),
                          const SizedBox(height: 10),
                          Center(
                            child: Image.network(
                              'http://pngimg.com/uploads/google/google_PNG19635.png',
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            ),
                          ),
                          const SizedBox(height: 20),

                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: "Don't have an account? ",
                                children: [
                                  TextSpan(
                                    text: "Sign Up",
                                    style: TextStyle(
                                      color: const Color(0xFFD3B073),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/signup',
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
