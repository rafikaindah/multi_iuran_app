import 'package:flutter/material.dart';
import 'admin_iuran/dashboard_page.dart';
import 'admin_iuran/peserta_page.dart';
import 'admin_iuran/transaksi_page.dart';
import 'admin_iuran/laporan_page.dart';

//halaman utama admin iuran
class DashboardAdminIuranPage extends StatefulWidget {
  final Map<String, dynamic> iuran;
  //data iuran yang dipilih admin
  const DashboardAdminIuranPage({super.key, required this.iuran});

  //dashboard utama admin iuran dengan bottom navigation
  @override
  State<DashboardAdminIuranPage> createState() =>
      _DashboardAdminIuranPageState();
}

//state untuk dashboard admin iuran
class _DashboardAdminIuranPageState extends State<DashboardAdminIuranPage> {
  //index halaman yang dipilih
  int selectedIndex = 0;
  //list halaman untuk dashboard, peserta, transaksi, dan laporan
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      DashboardPage(iuran: widget.iuran), //index 0 untuk dashboard
      PesertaPage(iuran: widget.iuran), //index 1 untuk peserta
      TransaksiPage(iuran: widget.iuran), //index 2 untuk transaksi
      LaporanPage(iuran: widget.iuran), //index 3 untuk laporan
    ];
  }

  @override
  Widget build(BuildContext context) {
    final iuranAktif = widget.iuran['status'] == 'aktif';

    return Scaffold(
      body: Column(
        children: [
          // card peringatan jika iuran tidak aktif
          if (!iuranAktif)
            Card(
              color: Colors.orange.shade100,
              margin: const EdgeInsets.all(12),
              child: const ListTile(
                leading: Icon(Icons.warning, color: Colors.orange),
                title: Text(
                  "Iuran Tidak Aktif",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Data masih dapat dilihat, tetapi peserta dan transaksi tidak dapat dikelola.",
                ),
              ),
            ),

          Expanded(
            child: pages[selectedIndex],
          ), //menampilkan halaman sesuai index yang dipilih
        ],
      ),

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

          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Peserta'),

          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'Transaksi',
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
