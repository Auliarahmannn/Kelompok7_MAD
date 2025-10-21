import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 250,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/gambar1.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 250,
          color: Colors.black.withOpacity(0.4),
        ),
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              const Text(
                'Good Night,',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Sunrise',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
