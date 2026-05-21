import 'package:flutter/material.dart';

//halaman laporan
class LaporanPage extends StatelessWidget {
  final Map<String, dynamic> iuran;

  const LaporanPage({super.key, required this.iuran});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Laporan ${iuran['nama_iuran']}",
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
