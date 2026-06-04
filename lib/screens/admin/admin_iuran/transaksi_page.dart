import 'package:flutter/material.dart';
import 'transaksi/pembayaran_page.dart';
import 'transaksi/pemasukan_page.dart';
import 'transaksi/pengeluaran_page.dart';

//halaman transaksi admin iuran
class TransaksiPage extends StatefulWidget {
  final Map<String, dynamic> iuran;

  const TransaksiPage({super.key, required this.iuran});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

// state untuk halaman transaksi
class _TransaksiPageState extends State<TransaksiPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final Color primaryColor = const Color.fromARGB(255, 100, 161, 102);

  @override
  void initState() {
    super.initState();

    // jumlah tab
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  // fungsi untuk membersihkan controller saat halaman tidak digunakan
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        title: Text("Transaksi ${widget.iuran['nama_iuran']}"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Pembayaran"),
            Tab(text: "Pemasukan"),
            Tab(text: "Pengeluaran"),
          ],
        ),
      ),

      body: TabBarView(
        controller: tabController,

        children: [
          PembayaranPage(iuran: widget.iuran),
          PemasukanPage(iuran: widget.iuran),
          PengeluaranPage(iuran: widget.iuran),
        ],
      ),
    );
  }
}
