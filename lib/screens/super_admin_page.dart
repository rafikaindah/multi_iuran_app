import 'package:flutter/material.dart';

import 'super_admin/dashboard_page.dart';
import 'super_admin/warga_page.dart';
import 'super_admin/iuran_page.dart';
import 'super_admin/admin_page.dart';
import 'super_admin/laporan_page.dart';

//class utama
class SuperAdminPage extends StatefulWidget {
  const SuperAdminPage({super.key});

  //state
  @override
  State<SuperAdminPage> createState() => _SuperAdminPageState();
}

class _SuperAdminPageState extends State<SuperAdminPage> {
  int selectedIndex = 0; //default index untuk halaman dashboard

  final pages = [
    const DashboardPage(), //index 0
    const WargaPage(), //index 1
    const IuranPage(), //index 2
    const AdminPage(), //index 3
    const LaporanPage(), //index 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          pages[selectedIndex], //menampilkan halaman sesuai index yang dipilih

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex, //menandai index yang aktif
        onTap: (index) {
          //mengubah index saat item ditekan
          setState(() {
            selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, //menampilkan semua item sama rata
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Warga'),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Iuran'),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }
}
