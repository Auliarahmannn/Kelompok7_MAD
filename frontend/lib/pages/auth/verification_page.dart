import 'package:flutter/material.dart';

class VerificationPage extends StatelessWidget {
  const VerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final codeController = TextEditingController();

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
                onPressed: () {
                  // TODO: verifikasi kode ke backend
                },
                child: const Text("Verify"),
              ),
              TextButton(
                onPressed: () {
                  // TODO: kirim ulang kode
                },
                child: const Text(
                  "Kirim Ulang Kode",
                  style: TextStyle(color: Colors.black87),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
