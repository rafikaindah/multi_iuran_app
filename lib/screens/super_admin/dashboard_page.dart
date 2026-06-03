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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Logout",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Apakah yakin ingin keluar dari aplikasi?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color.fromARGB(255, 104, 104, 104)),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Batal"),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Logout"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 100, 161, 102),
        foregroundColor: Colors.white,
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

                      // avatar
                      Container(
                        padding: const EdgeInsets.all(5),

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color.fromARGB(255, 100, 161, 102),
                            width: 3,
                          ),
                        ),

                        child: const Icon(
                          Icons.account_circle,
                          size: 100,
                          color: Color.fromARGB(255, 100, 161, 102),
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Halo, Super Admin !",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 60, 60, 60),
                        ),
                      ),

                      const SizedBox(height: 100),

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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),

        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
