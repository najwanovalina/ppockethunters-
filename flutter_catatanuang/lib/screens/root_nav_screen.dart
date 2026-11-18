import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import 'home_screen.dart';
import 'invetaris_screen.dart';
import 'profile_screen.dart';

class RootNavScreen extends StatefulWidget {
  const RootNavScreen({super.key});

  @override
  State<RootNavScreen> createState() => _RootNavScreenState();
}

class _RootNavScreenState extends State<RootNavScreen> {
  int _currentIndex = 0;

  static const _pages = [
    HomeScreen(),
    InventarisScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: AppColor.primary,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'Inventaris'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
