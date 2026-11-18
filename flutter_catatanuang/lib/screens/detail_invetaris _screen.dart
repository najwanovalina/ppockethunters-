import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart'; 
import 'package:flutter_catatanuang/utils/app_color.dart'; 
import 'package:flutter_catatanuang/widgets/custom_dialog.dart'; 
import 'package:flutter_catatanuang/widgets/custom_snackbar.dart'; 
import 'package:uuid/uuid.dart'; 

class DetailInvetarisScreen extends StatelessWidget {
  final String ItemId; //  ID dokumen barang dari halaman sebelumnya

  const DetailInvetarisScreen({super.key, required this.ItemId});

  // jalan pas tombol "Ajukan Peminjaman" dikonfirmasi
  Future<void> _ajukanPinjam(
    BuildContext context,
    Map<String, dynamic> item,
  ) async {
    final user = FirebaseAuth.instance.currentUser; // Cek user yang lagi login
    if (user == null) return; // Kalau belum login, hentikan proses

    final uid = user.uid; // Ambil ID unik user
    final borrowId = const Uuid().v1(); // Bikin ID transaksi pinjam baru secara acak

    try {
      // 1. Simpan riwayat pinjam ke dalam folder users/{uid}/borrowings/{borrowId}
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("borrowings")
          .doc(borrowId)
          .set({
        "borrowId": borrowId, // ID transaksi
        "item_id": ItemId, // ID barang yang dipinjam
        "item_name": item["item_name"] ?? "Alat", // Nama barang
        "code": item['code'] ?? '-', // Kode serial barang
        "image": item['image'] ?? '', // Link foto barang
        "borrow_date": DateTime.now().toIso8601String(), // Tanggal & jam pinjam sekarang
      });

      // 2. Ubah status barang di koleksi 'items' jadi 'Borrowed' biar nggak bisa dipinjam orang lain
      await FirebaseFirestore.instance
          .collection("items")
          .doc(ItemId) // Langsung pakai ItemId dokumen asli biar pasti ketemu
          .update({"status": "Borrowed"});

      // Kalau layar masih terbuka, munculkan pesan hijau sukses
      if (context.mounted) {
        CustomSnackBar.showSuccess(context, "Pengajuan peminjaman berhasil!");
      }
    } catch (e) {
      // Kalau gagal simpan ke Firebase, munculkan pesan merah error
      if (context.mounted) {
        CustomSnackBar.showError(context, "Gagal meminjam: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Warna latar abu-abu sangat muda
      appBar: AppBar(
        title: const Text(
          "Detail Inventaris",
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.primary),
        ),
        backgroundColor: Colors.white, // Header putih bersih
        elevation: 0, // Hilangkan bayangan bawah header
        centerTitle: true, // Judul di tengah
        iconTheme: const IconThemeData(color: AppColor.primary), // Tombol back warna biru
      ),
      // Pantau data 1 barang secara langsung (real-time) dari koleksi 'items'
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("items")
            .doc(ItemId)
            .snapshots(),
        builder: (context, snapshot) {
          // Kalau ada error koneksi ke Firebase
          if (snapshot.hasError) {
            return const Center(child: Text("Gagal memuat data alat"));
          }
          // Kalau data masih proses loading
          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final itemData = snapshot.data?.data(); // Ambil isi data barang
          // Kalau barangnya ternyata sudah dihapus atau nggak ada
          if (itemData == null) {
            return const Center(child: Text("Data Alat tidak ditemukan"));
          }

          // Ambil teks status dari Firebase lalu rapikan spasinya
          final String status = (itemData['status'] ?? 'Available').toString().trim();
          // Cek apakah statusnya 'borrowed' (tidak peduli huruf besar/kecil)
          final bool isBorrowed = status.toLowerCase() == 'borrowed';
          // Kalau tidak sedang dipinjam (isBorrowed == false), berarti Available (bisa dipinjam)
          final bool isAvailable = !isBorrowed;
          final String imageUrl = (itemData['image'] ?? '').toString().trim();

          return Column(
            children: [
              // Bagian atas yang bisa di-scroll (Gambar + Info Detail)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Kotak Foto Barang
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20), // Lengkungan sudut foto
                      child: Container(
                        height: 210,
                        width: double.infinity,
                        color: AppColor.primaryExtraSoft, // Warna latar kalau foto lagi loading
                        child: Image.network(
                          itemData['image']?.toString().trim() ?? '',
                          fit: BoxFit.cover, // Foto penuh memenuhi kotak
                          // Kalau link foto rusak/kosong, tampilkan ikon mikroskop biru
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.biotech_rounded,
                            size: 80,
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Baris Kategori, Nama Alat, dan Kotak Status di kanan
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Teks Kategori (misal: Elektronika)
                              Text(
                                itemData['category']?.toString() ?? '-',
                                style: const TextStyle(
                                  color: AppColor.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Nama Barang ukuran besar
                              Text(
                                itemData['item_name']?.toString() ?? '-',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Badge Status (Hijau kalau Available, Oranye kalau Borrowed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: (isAvailable ? AppColor.success : AppColor.warning).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            status.isEmpty ? 'Available' : status,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isAvailable ? AppColor.success : AppColor.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Kartu Putih berisi Kode Serial, Status, dan Spesifikasi
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColor.secondaryExtraSoft),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Baris Kode Serial
                          _infoItem(
                            Icons.qr_code_rounded,
                            "Kode Serial",
                            itemData['code']?.toString() ?? '-',
                          ),
                          const Divider(height: 24, color: AppColor.secondaryExtraSoft), // Garis pemisah tipis
                          // Baris Status Alat
                          _infoItem(
                            Icons.info_outline_rounded,
                            "Status Alat",
                            status.isEmpty ? 'Available' : status,
                          ),
                          const Divider(height: 24, color: AppColor.secondaryExtraSoft),
                          // Judul Spesifikasi
                          const Text(
                            "Spesifikasi Alat",
                            style: TextStyle(fontSize: 12, color: AppColor.secondarySoft),
                          ),
                          const SizedBox(height: 6),
                          // Isi Spesifikasi
                          Text(
                            (itemData['spesification'] ?? '').toString().isEmpty
                                ? "Tidak ada keterangan spesifikasi."
                                : itemData['spesification'].toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColor.secondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Area Tombol Pinjam yang nempel di bagian bawah layar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColor.secondaryExtraSoft)),
                ),
                child: SizedBox(
                  width: double.infinity, // Lebar tombol penuh kiri ke kanan
                  height: 50, // Tinggi tombol
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      // Biru kalau Available (bisa diklik), abu-abu kalau Borrowed (terkunci)
                      backgroundColor: isAvailable ? AppColor.primary : AppColor.secondarySoft,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    // Kalau Available -> munculkan pop-up konfirmasi pinjam. Kalau Borrowed -> tombol dimatikan (null)
                    onPressed: isAvailable
                        ? () => CustomDialog.showConfirmation(
                              context: context,
                              title: "Ajukan Peminjaman",
                              message: "Yakin ingin meminjam ${itemData['item_name']}?",
                              onConfirm: () => _ajukanPinjam(context, itemData),
                            )
                        : null,
                    icon: Icon(
                      isAvailable ? Icons.handshake_outlined : Icons.lock_clock,
                      color: Colors.white,
                    ),
                    label: Text(
                      isAvailable ? "Ajukan Peminjaman" : "Sedang Dalam Peminjaman",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Fungsi kecil buat bikin tampilan baris info (Ikon biru muda di kiri + teks di kanan)
  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.primaryExtraSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColor.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColor.secondarySoft),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                softWrap: true,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColor.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}