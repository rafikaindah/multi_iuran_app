import 'package:flutter/material.dart';

//halaman peserta
class PesertaPage extends StatelessWidget {
  final Map<String, dynamic> iuran;

  const PesertaPage({super.key, required this.iuran});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Peserta ${iuran['nama_iuran']}",
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
