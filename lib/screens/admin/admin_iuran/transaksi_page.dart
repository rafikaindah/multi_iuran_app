import 'package:flutter/material.dart';

//halaman transaksi
class TransaksiPage extends StatelessWidget {
  final Map<String, dynamic> iuran;

  const TransaksiPage({super.key, required this.iuran});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Transaksi ${iuran['nama_iuran']}",
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
