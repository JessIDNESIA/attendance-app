import 'package:attendance/ui/absent/absent_screen.dart';
import 'package:attendance/ui/attend/attend_screen.dart';
import 'package:attendance/ui/attendance_history/attendance_history.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // === TEMA ORANGE PROFESIONAL ===
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color accentOrange = Color(0xFFFF8C42);
  static const Color background = Color(0xFFFFFAF5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          // ================== TOP NAVBAR ADMIN ==================
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryOrange, accentOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                // Foto Profil Admin
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 29,
                    backgroundImage: const AssetImage('assets/images/admin_avatar.jpeg'), // Ganti dengan foto admin
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryOrange, width: 3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Greeting & Nama
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selamat Datang,",
                        style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                      ),
                      const Text(
                        "Admin IDN Boarding School",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Admin Panel • ${DateTime.now().year}",
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
                // Icon Notifikasi / Logout (opsional nanti)
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // ================== JUDUL UTAMA ==================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: primaryOrange,
            child: const Center(
              child: Text(
                "Attendance - Flutter App Admin",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // ================== MAIN MENU ==================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildMenuCard(
                    context: context,
                    imagePath: 'assets/images/ic_absen.png',
                    title: "Attendance Record",
                    description: "Catat absensi harian santri",
                    targetScreen: const AbsentScreen(),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context: context,
                    imagePath: 'assets/images/ic_leave.png',
                    title: "Leave Application",
                    description: "Pengajuan izin / sakit / pulang",
                    targetScreen: const AttendScreen(),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context: context,
                    imagePath: 'assets/images/ic_history.png',
                    title: "Attendance History",
                    description: "Riwayat lengkap kehadiran santri",
                    targetScreen: const AttendanceHistoryScreen(),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // ================== FOOTER ALL RIGHTS RESERVED ==================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: primaryOrange,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "© ${DateTime.now().year} IDN Boarding School Solo",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  "All Rights Reserved • Powered by Flutter",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String description,
    required Widget targetScreen,
  }) {
    return Card(
      elevation: 12,
      shadowColor: primaryOrange.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: primaryOrange.withOpacity(0.3), width: 2),
          ),
          child: Row(
            children: [
              // Ikon dengan background putih + shadow
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Image.asset(
                  imagePath,
                  height: 56,
                  width: 56,
                ),
              ),
              const SizedBox(width: 20),
              // Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: primaryOrange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: accentOrange,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}