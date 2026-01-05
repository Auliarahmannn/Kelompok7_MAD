import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import '/widgets/custom_button.dart';
import 'payment_success_dialog.dart';
import '/models/cart_model.dart';
import '/models/payment_method_model.dart';
import '/services/order_service.dart';

class PaymentDetailPage extends StatefulWidget {
  final int totalPrice;
  final List<CartItemModel> itemsToCheckout;
  final PaymentMethodModel selectedPaymentMethod;
  final int orderId;

  const PaymentDetailPage({
    super.key,
    required this.totalPrice,
    required this.itemsToCheckout,
    required this.selectedPaymentMethod,
    required this.orderId,
  });

  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  bool _isUploading = false;
  File? _pickedImage;
  String? _proofUrl;
  bool _isFetchingProof = true;
  final GlobalKey _proofAreaKey = GlobalKey();

  // Timer variables
  Timer? _countdownTimer;
  late DateTime _expiryTime;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fetchProofStatus();
    _initializeTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Inisialisasi timer (24 jam dari sekarang)
  void _initializeTimer() {
    _expiryTime = DateTime.now().add(const Duration(hours: 24));
    _updateRemainingTime();
    _startCountdown();
  }

  // Mulai countdown timer
  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateRemainingTime();
        });

        // Jika waktu habis
        if (_remainingTime.inSeconds <= 0) {
          timer.cancel();
          _showTimeExpiredDialog();
        }
      }
    });
  }

  // Update remaining time
  void _updateRemainingTime() {
    final now = DateTime.now();
    if (_expiryTime.isAfter(now)) {
      _remainingTime = _expiryTime.difference(now);
    } else {
      _remainingTime = Duration.zero;
    }
  }

  // Format countdown string
  String _formatCountdown() {
    if (_remainingTime.inSeconds <= 0) {
      return 'Waktu habis';
    }

    final hours = _remainingTime.inHours;
    final minutes = _remainingTime.inMinutes.remainder(60);
    final seconds = _remainingTime.inSeconds.remainder(60);

    return '$hours jam ${minutes.toString().padLeft(2, '0')} menit ${seconds.toString().padLeft(2, '0')} detik';
  }

  // Format tanggal jatuh tempo (tanpa package intl)
  String _formatExpiryDate() {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${_expiryTime.day} ${months[_expiryTime.month - 1]} ${_expiryTime.year}';
  }

  // Format waktu jatuh tempo
  String _formatExpiryTime() {
    final hour = _expiryTime.hour.toString().padLeft(2, '0');
    final minute = _expiryTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Dialog ketika waktu habis
  void _showTimeExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Waktu Pembayaran Habis'),
        content: const Text(
          'Batas waktu pembayaran telah berakhir. Silakan buat pesanan baru.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close payment page
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? xFile = await picker.pickImage(source: ImageSource.gallery);

      if (!mounted) return;

      if (xFile != null) {
        setState(() {
          _pickedImage = File(xFile.path);
        });
        if (_proofAreaKey.currentContext != null) {
          Scrollable.ensureVisible(
            _proofAreaKey.currentContext!,
            duration: const Duration(milliseconds: 500),
            alignment: 1.0,
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  Future<void> _handleUploadProof() async {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih foto bukti pembayaran terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final result = await OrderService.uploadPaymentProof(
        widget.orderId,
        _pickedImage!,
      );

      if (!mounted) return;

      if (result['status'] == true) {
        final String imageBaseUrl = 'http://10.0.2.2:8000/';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Bukti pembayaran berhasil diupload! Menunggu konfirmasi Admin.',
            ),
            backgroundColor: Color(0xFF5D7F5F),
          ),
        );
        setState(() {
          _proofUrl = imageBaseUrl + result['data']['proof_path'];
          _pickedImage = null;
        });
        _showSuccessDialog(context);
      } else {
        final String errorMessage =
            result['message'] ?? 'Upload gagal. Coba lagi.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error Upload: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _fetchProofStatus() async {
    setState(() => _isFetchingProof = true);
    try {
      final detail = await OrderService.getCustomerPaymentDetail(
        widget.orderId,
      );
      if (mounted) {
        setState(() {
          _proofUrl = detail['proof_url'];
        });
        debugPrint('✅ Fetch Bukti Berhasil. URL Bukti: $_proofUrl');
      }
    } catch (e) {
      debugPrint('❌ Error fetching proof status: $e');
    } finally {
      if (mounted) setState(() => _isFetchingProof = false);
    }
  }

  Future<void> _processButtonAction() async {
    if (_pickedImage == null) {
      await _pickImage();
    } else {
      _handleUploadProof();
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PaymentSuccessDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String paymentName = widget.selectedPaymentMethod.metode;
    final String vaNumber = "781 8239 8765 0927";
    final String paymentLogoText = paymentName.split(' ').first;

    return Scaffold(
      body: Stack(
        children: [
          // Background header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=800',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Pembayaran',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Content
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Total Payment
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Pembayaran',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Rp.${_formatPrice(widget.totalPrice)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD4A574),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Countdown - UPDATED
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Bayar dalam',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      _formatCountdown(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _remainingTime.inHours < 1
                                            ? Colors.red[700]
                                            : Colors.orange[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Jatuh tempo',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      '${_formatExpiryDate()}\n${_formatExpiryTime()}',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Payment Method
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4F3495),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        paymentLogoText,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      paymentName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No. Rek/Virtual Account',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      vaNumber,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFD4A574),
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(text: vaNumber),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Nomor rekening disalin',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Salin',
                                        style: TextStyle(
                                          color: Color(0xFF5D7F5F),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Proses verifikasi kurang dari 10 menit setelah pembayaran berhasil',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Area Upload Bukti Pembayaran
                          _buildProofUploadArea(),

                          const SizedBox(height: 12),

                          // Transfer Bank Instructions
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Theme(
                              data:
                                  ThemeData(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                title: const Text(
                                  'Transfer Bank',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                trailing:
                                    const Icon(Icons.keyboard_arrow_down),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildStep(
                                          '1',
                                          'Klik Buka Aplikasi OVO dan login ke akun OVO',
                                        ),
                                        const SizedBox(height: 12),
                                        _buildStep(
                                          '2',
                                          'Masuk ke halaman Tranfer Virtual Account untuk memeriksa Virtual Account Number 781 8239 8765 0927',
                                        ),
                                        const SizedBox(height: 12),
                                        _buildStep(
                                          '3',
                                          'Pastikan jumlah pembayaran sudah benar dan klik selanjutnya',
                                        ),
                                      ],
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

                // Bottom button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: CustomButton(
                    text: _isUploading
                        ? 'Mengupload...'
                        : (_proofUrl != null
                            ? 'Bukti Terupload'
                            : (_pickedImage == null
                                ? 'Pilih Bukti Transfer'
                                : 'Upload Bukti Pembayaran')),
                    onPressed: _isUploading || _proofUrl != null
                        ? null
                        : () {
                            _processButtonAction();
                          },
                    icon: _isUploading
                        ? null
                        : (_proofUrl != null
                            ? Icons.check_circle
                            : (_pickedImage == null
                                ? Icons.add_photo_alternate
                                : Icons.cloud_upload)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofUploadArea() {
    if (_isFetchingProof) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final String? finalImagePath = _proofUrl ?? _pickedImage?.path;
    final bool isLocalFile = _pickedImage != null;

    final ImageProvider? imageProvider = finalImagePath != null
        ? (isLocalFile
            ? FileImage(File(finalImagePath)) as ImageProvider
            : NetworkImage(finalImagePath))
        : null;

    return Container(
      key: _proofAreaKey,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bukti Pembayaran',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (imageProvider != null)
            Stack(
              alignment: Alignment.topRight,
              children: [
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Text("Gagal Muat Bukti (URL/Path salah)"),
                        ),
                      ),
                    ),
                  ),
                ),
                if (isLocalFile)
                  Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 20,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _pickedImage = null;
                        });
                      },
                    ),
                  ),
              ],
            )
          else
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.image_search,
                        size: 40, color: Colors.grey[500]),
                    const SizedBox(height: 8),
                    Text(
                      'Ketuk untuk memilih foto bukti transfer',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}