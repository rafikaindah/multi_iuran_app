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
      backgroundColor: const Color(0xffF5F7FA),
      //tampilkan list iuran aktif admin
      appBar: AppBar(
        title: const Text("Pilih Iuran"),
        backgroundColor: const Color.fromARGB(255, 100, 161, 102),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Expanded(
              child: ListView.builder(
                itemCount: iuranList.length,

                itemBuilder: (context, index) {
                  final iuran = iuranList[index];

                  final bool aktif = iuran['status_relasi'] == 'aktif';

                  //kartu iuran untu memilih iuran
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),

                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),

                      title: Text(
                        iuran['nama_iuran'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),

                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),

                              child: Text(
                                aktif ? "Aktif" : "Tidak Aktif",

                                style: TextStyle(
                                  color:
                                      aktif
                                          ? Colors.green.shade800
                                          : Colors.red.shade800,

                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      //navigasi ke dashboard iuran yang dipilih
                      onTap: () {
                        //jika iuran tidak aktif
                        if (!aktif) {
                          showDialog(
                            context: context,

                            builder: (_) {
                              return AlertDialog(
                                title: const Text("Akses Ditolak"),

                                content: const Text(
                                  "Anda dinonaktifkan sebagai admin iuran ini",
                                ),

                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },

                                    child: const Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );

                          return;
                        }

                        //jika iuran aktif
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => DashboardAdminIuranPage(iuran: iuran),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
