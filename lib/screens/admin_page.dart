import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin/dashboard_admin_iuran_page.dart';
import 'admin/pilih_iuran_page.dart';

//halaman utama admin iuran
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final supabase = Supabase.instance.client;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    cekIuranAdmin();
  }

  //cek iuran admin login
  Future<void> cekIuranAdmin() async {
    final userId = supabase.auth.currentUser!.id;

    //ambil data admin
    final adminData =
        await supabase
            .from('admin_iuran')
            .select()
            .eq('user_id', userId)
            .single();

    final adminId = adminData['id'];

    //ambil relasi iuran admin
    final data = await supabase
        .from('admin_iuran_relasi')
        .select('''
              status,

              iuran (
                id,
                nama_iuran,
                nominal,
                periode,
                status
              )
            ''')
        .eq('admin_id', adminId)
        .eq('status', 'aktif');

    //ambil hanya iuran aktif
    final iuranList =
        data
            .where((item) => item['iuran']['status'] == 'aktif')
            .map<Map<String, dynamic>>(
              (item) => item['iuran'] as Map<String, dynamic>,
            )
            .toList();

    //jika hanya 1 iuran
    if (iuranList.length == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardAdminIuranPage(iuran: iuranList.first),
        ),
      );
    }
    //jika lebih dari 1 iuran
    else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PilihIuranPage(iuranList: iuranList)),
      );
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox(),
    );
  }
}
