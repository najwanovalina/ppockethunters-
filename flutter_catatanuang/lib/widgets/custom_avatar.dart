import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import '../screens/profile_screen.dart';

class CuteAvatar extends StatelessWidget {
  final double size;
  final Color? avatarColor;
  final VoidCallback? onTap;

  const CuteAvatar({
    super.key,
    this.size = 80,
    this.avatarColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: avatarColor ?? AppTheme.pinkAccent,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Mata Kiri
            Positioned(
              left: size * 0.28,
              top: size * 0.35,
              child: Container(
                width: size * 0.15,
                height: size * 0.2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: size * 0.08,
                    height: size * 0.08,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),

            // Mata Kanan
            Positioned(
              right: size * 0.28,
              top: size * 0.35,
              child: Container(
                width: size * 0.15,
                height: size * 0.2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: size * 0.08,
                    height: size * 0.08,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),

            // Senyum
            Positioned(
              bottom: size * 0.25,
              child: Container(
                width: size * 0.15,
                height: size * 0.08,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}