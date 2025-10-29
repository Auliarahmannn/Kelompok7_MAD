import 'package:flutter/material.dart';
import 'package:campgear/models/product_model.dart';
import 'package:campgear/services/product_service.dart';
import '../../widgets/admin_drawer.dart';

class ManageProductPage extends StatefulWidget {
  const ManageProductPage({super.key});

  @override
  State<ManageProductPage> createState() => _ManageProductPageState();
}

class _ManageProductPageState extends State<ManageProductPage> {
  List<Products> produk = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final data = await ProductService.getProducts();
      setState(() {
        produk = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Gagal memuat produk: $e");
      setState(() => isLoading = false);
    }
  }

  void _showProductDialog({Products? existingProduct}) {
    final namaController = TextEditingController(
      text: existingProduct?.namaProduk ?? '',
    );
    final deskripsiController = TextEditingController(
      text: existingProduct?.deskripsi ?? '',
    );
    final hargaController = TextEditingController(
      text: existingProduct?.harga.toString() ?? '',
    );
    final stokController = TextEditingController(
      text: existingProduct?.stok.toString() ?? '',
    );
    final fotoController = TextEditingController(
      text: existingProduct?.foto ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingProduct == null ? "Tambah Produk" : "Edit Produk"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: "Nama Produk"),
              ),
              TextField(
                controller: deskripsiController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
              ),
              TextField(
                controller: hargaController,
                decoration: const InputDecoration(labelText: "Harga"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stokController,
                decoration: const InputDecoration(labelText: "Stok"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: fotoController,
                decoration: const InputDecoration(labelText: "URL Foto"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final nama = namaController.text;
              final desk = deskripsiController.text;
              final harga = double.tryParse(hargaController.text) ?? 0;
              final stok = int.tryParse(stokController.text) ?? 0;
              final foto = fotoController.text;

              bool success;
              if (existingProduct == null) {
                success = await ProductService.createProduct(
                  namaProduk: nama,
                  deskripsi: desk,
                  harga: harga,
                  stok: stok,
                  foto: foto,
                );
              } else {
                success = await ProductService.updateProduct(
                  id: existingProduct.id,
                  namaProduk: nama,
                  deskripsi: desk,
                  harga: harga,
                  stok: stok,
                  foto: foto,
                );
              }

              if (success && mounted) {
                Navigator.pop(context);
                fetchProducts();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      existingProduct == null
                          ? "Produk berhasil ditambahkan"
                          : "Produk berhasil diperbarui",
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Gagal menyimpan produk")),
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _hapusProduk(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin menghapus produk ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ProductService.deleteProduct(id);
      if (success) {
        fetchProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produk berhasil dihapus")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal menghapus produk")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(title: const Text("Kelola Produk")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchProducts,
              child: ListView.builder(
                itemCount: produk.length,
                itemBuilder: (context, index) {
                  final item = produk[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: item.foto.isNotEmpty
                            ? AssetImage('assets/images/${item.foto}')
                            : null,
                        backgroundColor: Colors.grey[200],
                        child: item.foto.isEmpty
                            ? const Icon(Icons.image_not_supported, size: 50)
                            : null,
                      ),
                      title: Text(item.namaProduk),
                      subtitle: Text("Rp${item.harga} | Stok: ${item.stok}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _showProductDialog(existingProduct: item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _hapusProduk(item.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add),
        onPressed: () => _showProductDialog(),
      ),
    );
  }
}
