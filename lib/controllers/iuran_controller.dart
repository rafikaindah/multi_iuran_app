import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/iuran_model.dart';

class IuranController {
  final supabase = Supabase.instance.client;

  //mengambil data iuran
  Future<List<IuranModel>> getIuran() async {
    final data = await supabase
        .from('iuran')
        .select()
        .order('created_at', ascending: false);

    return data.map<IuranModel>((item) {
      return IuranModel.fromMap(item);
    }).toList();
  }

  //tambah iuran baru
  Future<void> tambahIuran({
    required String namaIuran,
    int? nominal,
    String? periode,
  }) async {
    await supabase.from('iuran').insert({
      'nama_iuran': namaIuran,
      'nominal': nominal,
      'periode': periode,
      'status': 'aktif',
    });
  }

  //edit data iuran yang dipilih
  Future<void> editIuran({
    required String id,
    required String namaIuran,
    int? nominal,
    String? periode,
  }) async {
    await supabase
        .from('iuran')
        .update({
          'nama_iuran': namaIuran,
          'nominal': nominal,
          'periode': periode,
        })
        .eq('id', id);
  }

  //mengubah status iuran
  Future<void> updateStatus({
    required String id,
    required String status,
  }) async {
    await supabase.from('iuran').update({'status': status}).eq('id', id);
  }

  // mengambil iuran aktif saja
  Future<List<IuranModel>> getIuranAktif() async {
    final response = await supabase
        .from('iuran')
        .select()
        .eq('status', 'aktif');

    return response.map((item) => IuranModel.fromMap(item)).toList();
  }
}
