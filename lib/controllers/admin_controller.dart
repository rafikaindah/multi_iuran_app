import 'package:supabase_flutter/supabase_flutter.dart';

class AdminController {
  final supabase = Supabase.instance.client;

  //mengambil data admin beserta relasi iuran
  Future<List<Map<String, dynamic>>> getAdmin() async {
    final data = await supabase
        .from('admin_iuran_relasi')
        .select('''
          id,
          status,

          admin_iuran (
            id,
            nama,
            email,
            user_id
          ),

          iuran (
            id,
            nama_iuran,
            status
          )
        ''')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  //mengambil iuran aktif saja
  Future<List<Map<String, dynamic>>> getIuranAktif() async {
    final data = await supabase
        .from('iuran')
        .select()
        .eq('status', 'aktif')
        .order('nama_iuran');

    return List<Map<String, dynamic>>.from(data);
  }

  //tambah admin baru
  Future<void> tambahAdmin({
    required String nama,
    required String email,
    required String password,
    required List<String> iuranIds,
  }) async {
    //buat akun auth
    final authResponse = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final userId = authResponse.user!.id;

    //simpan role user
    await supabase.from('users').insert({
      'id': userId,
      'email': email,
      'role': 'admin',
    });

    //simpan data admin
    final adminData =
        await supabase
            .from('admin_iuran')
            .insert({'nama': nama, 'email': email, 'user_id': userId})
            .select()
            .single();

    final adminId = adminData['id'];

    //simpan relasi iuran
    for (final iuranId in iuranIds) {
      await supabase.from('admin_iuran_relasi').insert({
        'admin_id': adminId,
        'iuran_id': iuranId,
        'status': 'aktif',
      });
    }
  }

  //edit admin dan relasi iuran
  Future<void> editAdminLengkap({
    required String adminId,
    required String nama,
    required String email,
    required List<String> iuranIds,
  }) async {
    //update data admin
    await supabase
        .from('admin_iuran')
        .update({'nama': nama, 'email': email})
        .eq('id', adminId);

    //hapus relasi lama
    await supabase.from('admin_iuran_relasi').delete().eq('admin_id', adminId);

    //insert relasi baru
    for (final iuranId in iuranIds) {
      await supabase.from('admin_iuran_relasi').insert({
        'admin_id': adminId,
        'iuran_id': iuranId,
        'status': 'aktif',
      });
    }
  }

  //mengubah status relasi
  Future<void> updateStatusRelasi({
    required String relasiId,
    required String status,
  }) async {
    await supabase
        .from('admin_iuran_relasi')
        .update({'status': status})
        .eq('id', relasiId);
  }
}
