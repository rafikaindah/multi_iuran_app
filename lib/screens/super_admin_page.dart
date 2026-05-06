import 'package:flutter/material.dart';

class SuperAdminPage extends StatelessWidget {
  const SuperAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Super Admin")),
      body: Center(child: Text("Dashboard Super Admin")),
    );
  }
}
