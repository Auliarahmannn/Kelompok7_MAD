import 'package:campgear/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'verification_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  bool obscurePassword = true;
  bool obscureRepeatPassword = true;

  void handleSignUp() async {
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final repeatPassword = repeatPasswordController.text;
    final phone = phoneController.text.trim(); // 🔥 Data Phone
    final address = addressController.text.trim(); // 🔥 Data Address

    // ✅ Validasi sederhana
    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        repeatPassword.isEmpty ||
        phone.isEmpty ||
        address.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field wajib diisi')));
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 8 karakter')),
      );
      return;
    }

    if (password != repeatPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password dan Ulangi Password tidak cocok'),
        ),
      );
      return;
    }

    // Panggil backend untuk kirim kode verifikasi
    final response = await AuthService.sendCode(email);

    final status = response['status'];
    if (!mounted) return;

    if (status == true || status == 1 || status == 'success') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationPage(
            email: email,
            name: username,
            password: password,
            phone: phone, // Kirim Phone
            address: address, // Kirim Address
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Gagal mengirim kode')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF587C4E), // hijau
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/loginlogo.png', height: 150),
              const SizedBox(height: 20),
              Container(
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
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: "Masukan Email Anda",
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text("Username"),
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        hintText: "Masukan Username Anda",
                      ),
                    ),

                    // 🔥 FIELD BARU: Phone
                    const SizedBox(height: 16),
                    const Text("Phone Number"),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: "Masukan Nomor Telepon Anda",
                      ),
                    ),

                    // 🔥 FIELD BARU: Address
                    const SizedBox(height: 16),
                    const Text("Address"),
                    TextField(
                      controller: addressController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: "Masukan Alamat Lengkap Anda",
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

                    const SizedBox(height: 16),
                    const Text("Repeat Password"),
                    TextField(
                      controller: repeatPasswordController,
                      obscureText: obscureRepeatPassword,
                      decoration: InputDecoration(
                        hintText: "Ulangi Password Anda",
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureRepeatPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureRepeatPassword = !obscureRepeatPassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: const Color(0xFFD3B073),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: handleSignUp,
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(child: Text("OR")),
                    const SizedBox(height: 10),
                    Center(
                      child: Image.network(
                        'http://pngimg.com/uploads/google/google_PNG19635.png', // gambar google
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: "Already have account? ",
                          style: const TextStyle(color: Colors.black87),
                          children: [
                            TextSpan(
                              text: "Sign In",
                              style: TextStyle(
                                color: const Color(0xFFD3B073),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/signin',
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
            ],
          ),
        ),
      ),
    );
  }
}
