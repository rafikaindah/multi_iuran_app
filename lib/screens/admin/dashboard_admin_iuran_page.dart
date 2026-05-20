import 'package:flutter/material.dart';

//dashboard admin iuran
class DashboardAdminIuranPage extends StatelessWidget {
  final Map<String, dynamic> iuran;

  const DashboardAdminIuranPage({super.key, required this.iuran});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(iuran['nama_iuran'])),

      body: Center(
        child: Text(
          "Dashboard ${iuran['nama_iuran']}",
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
