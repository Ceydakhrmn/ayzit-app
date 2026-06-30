import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DonguSplash extends StatelessWidget {
  const DonguSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, // Daha dengeli bir geçiş için
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE5D1FA), // Yumuşak Lavanta
              Color(0xFFFDEFF9), // Beyazımsı Pembe
              Color(0xFFCAE9FF), // Bebek Mavisi
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Merkezdeki Logo Alanı
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.1),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                // İkonları hizalamak için Padding ve doğru Stack kullanımı
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Arka plandaki ana çiçek yaprakları
                    Icon(
                      Icons.spa, 
                      size: 100, 
                      color: const Color(0xFFB19CD9).withValues(alpha: 0.8)
                    ),
                    // Ön tarafa eklenen hilal (Konumlandırmayı düzelttik)
                    Transform.translate(
                      offset: const Offset(0, 15), // Hilali çiçeğin altına doğru çeker
                      child: const Icon(
                        Icons.nightlight_round,
                        size: 30,
                        color: Color(0xFFD4A5A5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
            // Başlık
            Text(
              'DÖNGÜ',
              style: GoogleFonts.montserrat(
                fontSize: 45,
                fontWeight: FontWeight.w300, // Daha zarif bir görünüm için ince font
                letterSpacing: 15.0,
                color: const Color(0xFF5D5461),
              ),
            ),
            const SizedBox(height: 10),
            // Alt Başlık
            Text(
              'Takip ve Sağlık',
              style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                letterSpacing: 2.0,
                color: const Color(0xFF8E8294),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
