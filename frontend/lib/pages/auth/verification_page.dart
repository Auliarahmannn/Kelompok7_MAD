import 'package:flutter/material.dart';
import 'package:campgear/services/auth_service.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  final String name;
  final String password;
  final String phone;
  final String address;

  const VerificationPage({
    super.key,
    required this.email,
    required this.name,
    required this.password,
    required this.phone, // 🔥 Diperlukan
    required this.address, // 🔥 Diperlukan
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final codeController = TextEditingController();
  bool isLoading = false;

  void verifyCode() async {
    final code = codeController.text.trim();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode harus 6 digit')),
      );
      return;
    }

    setState(() => isLoading = true);

    final verify = await AuthService.verifyCode(widget.email, code);

    if (verify['status'] == 'success') {
      // Setelah OTP benar, lakukan registrasi dengan data lengkap
      final register = await AuthService.register(
        name: widget.name,
        email: widget.email,
        password: widget.password,
        phone: widget.phone, // 🔥 Gunakan Phone dari Sign Up Page
        address: widget.address, // 🔥 Gunakan Address dari Sign Up Page
      );

      if (register['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
        );
        Navigator.pushReplacementNamed(context, '/signin');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(register['message'] ?? 'Gagal register')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(verify['message'] ?? 'Kode verifikasi salah')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/onboarding2.png', height: 150),
              const SizedBox(height: 20),
              const Text(
                "Verification Code",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: codeController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  hintText: "Masukan kode 6 digit",
                  counterText: "",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFFD3B073),
                ),
                onPressed: isLoading ? null : verifyCode,
                child: Text(isLoading ? "Memverifikasi..." : "Verify"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
