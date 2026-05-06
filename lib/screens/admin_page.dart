import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Iuran")),
      body: Center(child: Text("Dashboard Admin Iuran")),
    );
  }
}
