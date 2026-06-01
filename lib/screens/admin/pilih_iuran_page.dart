import 'package:flutter/material.dart';

import 'dashboard_admin_iuran_page.dart';

//halaman memilih iuran admin
class PilihIuranPage extends StatelessWidget {
  //list iuran aktif admin
  final List<Map<String, dynamic>> iuranList;

  const PilihIuranPage({super.key, required this.iuranList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Iuran")),
      //tampilkan list iuran aktif admin
      body: ListView.builder(
        itemCount: iuranList.length,

        itemBuilder: (context, index) {
          final iuran = iuranList[index];
          //kartu iuran untu memilih iuran
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(iuran['nama_iuran']),
              subtitle: Text("Status: ${iuran['status']}"),
              trailing: const Icon(Icons.arrow_forward_ios),
              //navigasi ke dashboard iuran yang dipilih
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DashboardAdminIuranPage(iuran: iuran),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
