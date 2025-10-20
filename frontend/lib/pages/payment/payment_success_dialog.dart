import 'package:flutter/material.dart';
import '/widgets/custom_button.dart';

class PaymentSuccessDialog extends StatelessWidget {
  const PaymentSuccessDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pembayaran berhasil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Kembali ke Home',
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              icon: Icons.home,
            ),
            const SizedBox(height: 16),
            // Product recommendations
            const Text(
              'Rekomendasi Carrier',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildProductCard(
                    'Carrier Eiger 70 L',
                    'Rp. 50.000/hari',
                    'https://images.unsplash.com/photo-1622260614153-03223fb72052?w=200',
                  ),
                  _buildProductCard(
                    'Carrier Eiger 60 L',
                    'Rp. 40.000/hari',
                    'https://images.unsplash.com/photo-1622260614153-03223fb72052?w=200',
                  ),
                  _buildProductCard(
                    'Carrier Eiger 80 L',
                    'Rp. 55.000/hari',
                    'https://images.unsplash.com/photo-1622260614153-03223fb72052?w=200',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(String name, String price, String imageUrl) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF5D7F5F),
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF5D7F5F),
            ),
          ),
        ],
      ),
    );
  }
}