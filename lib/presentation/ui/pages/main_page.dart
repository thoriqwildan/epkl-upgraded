// lib/presentation/ui/pages/main_page.dart

import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:epkl/presentation/ui/pages/attendance_page.dart';
import 'package:epkl/presentation/ui/pages/journal_page.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _page = 2;

  static const List<Widget> _pages = <Widget>[
    SizedBox.shrink(),
    JournalListPage(),
    HomePage(),
    AttendanceListPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Definisikan warna di sini agar lebih rapi dan konsisten
    final iconColor = Theme.of(
      context,
    ).bottomNavigationBarTheme.selectedItemColor;
    final labelStyle = TextStyle(
      color: iconColor,
      fontWeight: FontWeight.w500,
      fontSize: 11,
    );

    return Scaffold(
      // Tidak perlu extendBody, FloatingActionButton, atau BottomAppBar
      body: _pages[_page],
      bottomNavigationBar: CurvedNavigationBar(
        index: _page,
        items: [
          CurvedNavigationBarItem(
            child: Icon(Icons.settings_outlined, color: iconColor),
            label: 'Setting',
            labelStyle: labelStyle,
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.book_outlined, color: iconColor),
            label: 'Jurnal',
            labelStyle: labelStyle,
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.home_filled, color: iconColor, size: 35),
            label: 'Home',
            labelStyle: labelStyle,
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.check_circle_outline, color: iconColor),
            label: 'Absensi',
            labelStyle: labelStyle,
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.person_outline, color: iconColor),
            label: 'Profil',
            labelStyle: labelStyle,
          ),
        ],
        // Properti lain untuk styling
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor!,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Theme.of(context).primaryColor,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        height: 65, // Sesuaikan tinggi jika perlu
        onTap: (index) {
          // Logika saat item di-tap
          if (index == 0) {
            // Jika item tengah (Tambah) ditekan, lakukan aksi
            // (misalnya, navigasi ke halaman baru)
            print('Buka halaman setting!');
            // Navigator.push(context, MaterialPageRoute(builder: (context) => AddJournalPage()));

            // Kita tidak memanggil setState, jadi halaman di belakangnya tidak berubah.
          } else {
            // Jika item lain ditekan, ganti halaman seperti biasa
            setState(() {
              _page = index;
            });
          }
        },
      ),
    );
  }
}
