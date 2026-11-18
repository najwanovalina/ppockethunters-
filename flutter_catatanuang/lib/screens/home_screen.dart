import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_catatanuang/screens/invetaris_screen.dart';
import '../utils/app_color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = "";
  String _selectedCategory = "Semua";
  String _selectedStatus = "Available";

  final List<String> _categories = [
    "Semua",
    "Elektronika",
    "Jaringan",
    "Komputer",
    "Sensor",
  ];

  final List<Map<String, String>> _banners = [
    {
      "title": "Lab Praktikum Terpadu",
      "subtitle": "Cek ketersediaan alat sebelum memulai praktikum",
      "image":
          "https://images.unsplash.com/photo-1581092921461-eab62e97a780?w=800",
    },
    {
      "title": "Peminjaman Real-Time",
      "subtitle": "Pantau status alat Available & Borrowed langsung dari HP",
      "image":
          "https://images.unsplash.com/photo-1518770660439-4636190af475?w=800",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Silakan login kembali.")),
      );
    }

    final uid = user.uid;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  final userData =
                      (snapshot.data?.data() as Map<String, dynamic>?) ?? {};
                  final name = userData['name']?.toString() ?? 'Siswa Lab';
                  final kelas = userData['kelas']?.toString() ?? '';
                  final foto =
                      userData['foto']?.toString() ??
                      'https://ui-avatars.com/api/?name=Lab';

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.science,
                                color: AppColor.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "LabSync • $kelas",
                                style: const TextStyle(
                                  color: AppColor.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Welcome, $name",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColor.secondary,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColor.primaryExtraSoft,
                        backgroundImage: NetworkImage(foto),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColor.secondaryExtraSoft),
                ),
                child: TextField(
                  onChanged: (val) =>
                      setState(() => _searchQuery = val.toLowerCase()),
                  decoration: const InputDecoration(
                    hintText: "Search alat inventaris atau kode...",
                    hintStyle: TextStyle(
                      color: AppColor.secondarySoft,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(Icons.search, color: AppColor.primary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 145,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.88),
                itemCount: _banners.length,
                itemBuilder: (context, index) {
                  final banner = _banners[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(banner["image"]!),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          AppColor.primarySoft.withOpacity(0.65),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          banner["title"]!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          banner["subtitle"]!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Data inventaris gagal dimuat.',
                      style: TextStyle(color: AppColor.secondarySoft),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                final searchedDocs = docs.where((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>? ??
                      <String, dynamic>{};
                  final name = (data['item_name'] ?? '')
                      .toString()
                      .toLowerCase();
                  final code = (data['code'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) ||
                      code.contains(_searchQuery);
                }).toList();

                final categoryDocs = searchedDocs.where((doc) {
                  if (_selectedCategory == "Semua") return true;
                  final data =
                      doc.data() as Map<String, dynamic>? ??
                      <String, dynamic>{};
                  return (data['category'] ?? '') == _selectedCategory;
                }).toList();

                final statusDocs = categoryDocs.where((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>? ??
                      <String, dynamic>{};
                  return (data['status'] ?? '') == _selectedStatus;
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      "Semua Data Inventaris",
                      "${searchedDocs.length} Item",
                    ),
                    _buildHorizontalCards(searchedDocs),

                    const SizedBox(height: 18),

                    _buildSectionHeader(
                      "Kategori Peralatan",
                      _selectedCategory,
                    ),
                    SizedBox(
                      height: 36,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = cat == _selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              selectedColor: AppColor.primary,
                              backgroundColor: AppColor.primaryExtraSoft,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColor.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              side: BorderSide.none,
                              onSelected: (_) =>
                                  setState(() => _selectedCategory = cat),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildHorizontalCards(categoryDocs),

                    const SizedBox(height: 18),

                    _buildSectionHeader("Status Alat", _selectedStatus),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: ["Available", "Borrowed"].map((st) {
                          final isSelected = st == _selectedStatus;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(st),
                              selected: isSelected,
                              selectedColor: st == "Available"
                                  ? AppColor.success
                                  : AppColor.warning,
                              backgroundColor: AppColor.primaryExtraSoft,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColor.secondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              side: BorderSide.none,
                              onSelected: (_) =>
                                  setState(() => _selectedStatus = st),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildHorizontalCards(statusDocs),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String badgeText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.secondary,
            ),
          ),
          Text(
            badgeText,
            style: const TextStyle(
              fontSize: 12,
              color: AppColor.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCards(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Text(
          "Belum ada data alat di bagian ini.",
          style: TextStyle(color: AppColor.secondarySoft, fontSize: 13),
        ),
      );
    }

    return SizedBox(
      height: 185,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final itemId = docs[index].id;
          final item = (docs[index].data() as Map<String, dynamic>?) ?? {};
          final status = (item['status'] ?? 'Available').toString();
          final isAvailable = status == 'Available';
          final itemName =
              (item['item_name'] ?? item['name'] ?? item['itemName'])
                  ?.toString()
                  .trim();
          final categoryName =
              (item['category'] ??
                      item['category_name'] ??
                      item['categoryName'])
                  ?.toString()
                  .trim();
          final imageUrl = item['image']?.toString() ?? '';

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailInventarisScreen(itemId: itemId),
              ),
            ),
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColor.secondaryExtraSoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 90,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColor.primaryExtraSoft,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.devices_other,
                                color: AppColor.primary,
                                size: 36,
                              ),
                            )
                          : const Icon(
                              Icons.devices_other,
                              color: AppColor.primary,
                              size: 36,
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemName ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColor.secondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          categoryName ?? '-',
                          style: const TextStyle(
                            color: AppColor.secondarySoft,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? AppColor.success.withOpacity(0.15)
                                : AppColor.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isAvailable
                                  ? AppColor.success
                                  : AppColor.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}