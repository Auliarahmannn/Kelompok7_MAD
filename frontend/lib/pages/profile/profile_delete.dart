import 'package:flutter/material.dart';
import 'package:campgear/services/user_service.dart';
import 'package:campgear/services/auth_service.dart';

class ProfileDeletePage extends StatefulWidget {
  const ProfileDeletePage({super.key});

  @override
  State<ProfileDeletePage> createState() => _ProfileDeletePageState();
}

class _ProfileDeletePageState extends State<ProfileDeletePage> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isChecked = false;
  bool isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui konsekuensi penghapusan akun'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan password untuk konfirmasi'),
          backgroundColor: Color(0xFF5D7F5F),
        ),
      );
      return;
    }

    // Konfirmasi final
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Konfirmasi Akhir'),
          ],
        ),
        content: const Text(
          'Apakah Anda benar-benar yakin ingin menghapus akun ini? Tindakan ini tidak dapat dibatalkan!',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red, // ini untuk warna teks
            ),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Hapus Akun'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => isLoading = true);

    try {
      // Hapus 'final success ='
      await UserService.deleteAccount(password: _passwordController.text);

      // Ubah kondisi if, HANYA cek 'mounted'
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );

        // Logout dan langsung ke login page
        await AuthService.logout();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/signin',
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Pesan 'e' dari exception akan ditampilkan di sini jika gagal
            content: Text('Gagal menghapus akun: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Hapus Akun'),
        backgroundColor: const Color(0xFF5D7F5F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[300]!, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.green[700],
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Peringatan Penting!',
                          style: TextStyle(
                            color: Colors.green[900],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Menghapus akun Anda adalah tindakan permanen yang tidak dapat dibatalkan.',
                    style: TextStyle(color: Colors.green[800], fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Konsekuensi Section
            const Text(
              'Apa yang akan terjadi:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildConsequenceItem(
              icon: Icons.person_off,
              text: 'Akun Anda akan dihapus secara permanen',
            ),
            _buildConsequenceItem(
              icon: Icons.delete_forever,
              text: 'Semua data pribadi Anda akan dihapus',
            ),
            _buildConsequenceItem(
              icon: Icons.shopping_cart_outlined,
              text: 'Riwayat pesanan Anda akan dihapus',
            ),
            _buildConsequenceItem(
              icon: Icons.block,
              text: 'Anda tidak dapat mengakses akun ini lagi',
            ),
            _buildConsequenceItem(
              icon: Icons.restore_outlined,
              text: 'Data tidak dapat dipulihkan setelah dihapus',
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Password Confirmation
            const Text(
              'Konfirmasi Password',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Masukkan password Anda untuk mengkonfirmasi penghapusan akun',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),

            const SizedBox(height: 20),

            // Checkbox Agreement
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: CheckboxListTile(
                value: _isChecked,
                onChanged: (value) {
                  setState(() {
                    _isChecked = value ?? false;
                  });
                },
                title: const Text(
                  'Saya memahami bahwa tindakan ini tidak dapat dibatalkan dan semua data saya akan dihapus secara permanen.',
                  style: TextStyle(fontSize: 13),
                ),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.green,
              ),
            ),

            const SizedBox(height: 24),

            // Delete Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _deleteAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_forever),
                          SizedBox(width: 8),
                          Text(
                            'Hapus Akun Saya',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Batalkan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsequenceItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green[700], size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
