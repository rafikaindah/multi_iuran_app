import 'package:flutter/material.dart';

//dashboard admin iuran
class DashboardPage extends StatelessWidget {
  final Map<String, dynamic> iuran;

  const DashboardPage({super.key, required this.iuran});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Dashboard ${iuran['nama_iuran']}",
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
