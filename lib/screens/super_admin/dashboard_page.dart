import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../controllers/admin_controller.dart';
import '../../controllers/iuran_controller.dart';
import '../../controllers/warga_controller.dart';
import '../login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

// state untuk halaman dashboard super admin
class _DashboardPageState extends State<DashboardPage> {
  final adminController = AdminController();
  final wargaController = WargaController();
  final iuranController = IuranController();

  int totalAdmin = 0;
  int totalWarga = 0;
  int totalIuran = 0;

  bool isLoading = true;

  // loading
  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  // mengambil data dashboard
  Future<void> loadDashboard() async {
    try {
      // mengambil data admin aktif
      final adminData = await adminController.getAdminAktif();
      // mengambil data warga aktif
      final wargaData = await wargaController.getWargaAktif();
      // mengambil data iuran aktif
      final iuranData = await iuranController.getIuranAktif();

      setState(() {
        totalAdmin = adminData.length;
        totalWarga = wargaData.length;
        totalIuran = iuranData.length;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // fungsi logout
  Future<void> logout() async {
    final confirm = await showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah yakin untuk logout?"),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Batal"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    // jika batal
    if (confirm != true) return;
    // proses logout
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f1f1),

      appBar: AppBar(
        backgroundColor: const Color(0xfff5f1f1),
        elevation: 0,

        title: const Text("Beranda"),

        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),

      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      const Icon(
                        Icons.account_circle,
                        size: 100,
                        color: Colors.black,
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Halo, Super Admin !",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 50),

                      // card menu
                      Row(
                        children: [
                          Expanded(
                            child: DashboardMenuCard(
                              title: "Total\nAdmin",
                              value: "$totalAdmin",
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: DashboardMenuCard(
                              title: "Total\nWarga",
                              value: "$totalWarga",
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: DashboardMenuCard(
                              title: "Total\nIuran",
                              value: "$totalIuran",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

// widget card dashboard
class DashboardMenuCard extends StatelessWidget {
  final String title;
  final String value;

  const DashboardMenuCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
