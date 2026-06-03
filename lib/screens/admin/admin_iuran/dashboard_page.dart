import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../controllers/peserta_controller.dart';
import '../../login_page.dart';

//dashboard admin iuran
class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> iuran;

  const DashboardPage({super.key, required this.iuran});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

// state untuk halaman dashboard admin iuran
class _DashboardPageState extends State<DashboardPage> {
  final pesertaController = PesertaController();

  // warna utama
  final primaryColor = const Color.fromARGB(255, 100, 161, 102);

  int totalPeserta = 0;

  bool isLoading = true;

  String namaAdmin = "Admin";
  String namaIuran = "-";
  String nominalIuran = "0";
  String periodeIuran = "-";

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  // ambil data dashboard
  Future<void> loadDashboard() async {
    try {
      // ambil user login
      final user = Supabase.instance.client.auth.currentUser;
      // ambil data admin login
      final adminData =
          await Supabase.instance.client
              .from('admin_iuran')
              .select('nama')
              .eq('user_id', user!.id)
              .single();

      // ambil peserta aktif berdasarkan iuran
      final pesertaData = await pesertaController.getPesertaAktif(
        widget.iuran['id'],
      );

      // data iuran
      final iuran = widget.iuran;

      setState(() {
        totalPeserta = pesertaData.length;
        namaAdmin = adminData['nama'] ?? 'Admin';
        namaIuran = "Petugas Iuran ${iuran['nama_iuran'] ?? '-'}";
        nominalIuran = formatRupiah(iuran['nominal'] ?? 0);
        periodeIuran = iuran['periode'] ?? '-';

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

    // logout
    await Supabase.instance.client.auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  // format rupiah
  String formatRupiah(int nominal) {
    return nominal.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text("Beranda"),
        // tombol logout
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
                          border: Border.all(color: primaryColor, width: 3),
                        ),

                        child: Icon(
                          Icons.account_circle,
                          size: 100,
                          color: primaryColor,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        "Halo, $namaAdmin !",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 60, 60, 60),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        namaIuran,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 40),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),

                        child: Column(
                          children: [
                            const Text(
                              "Total Peserta",
                              style: TextStyle(fontSize: 18),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "$totalPeserta",
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),

                        child: Column(
                          children: [
                            const Text(
                              "Nominal Iuran",
                              style: TextStyle(fontSize: 18),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "Rp $nominalIuran",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),

                        child: Column(
                          children: [
                            const Text(
                              "Periode Iuran",
                              style: TextStyle(fontSize: 18),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              periodeIuran,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
