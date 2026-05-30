import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/warga_model.dart';

class WargaController {
  final supabase = Supabase.instance.client;

  //mengambil data warga
  Future<List<WargaModel>> getWarga() async {
    final data = await supabase
        .from('warga')
        .select()
        .order('created_at', ascending: false);

    return data.map<WargaModel>((item) {
      return WargaModel.fromMap(item);
    }).toList();
  }

  //tambah warga baru
  Future<void> tambahWarga({
    required String nama,
    required String alamat,
    required String noHp,
  }) async {
    await supabase.from('warga').insert({
      'nama': nama,
      'alamat': alamat,
      'no_hp': noHp,
      'status': 'aktif',
    });
  }

  //edit data warga yang dipilih
  Future<void> editWarga({
    required String id,
    required String nama,
    required String alamat,
    required String noHp,
  }) async {
    await supabase
        .from('warga')
        .update({'nama': nama, 'alamat': alamat, 'no_hp': noHp})
        .eq('id', id);
  }

  //mengubah status warga
  Future<void> updateStatus({
    required String id,
    required String status,
  }) async {
    // update status warga
    await supabase.from('warga').update({'status': status}).eq('id', id);
    // update semua peserta milik warga tersebut
    await supabase
        .from('peserta')
        .update({'status': status})
        .eq('warga_id', id);
  }

  // mengambil warga aktif saja
  Future<List<WargaModel>> getWargaAktif() async {
    final data = await supabase
        .from('warga')
        .select()
        .eq('status', 'aktif')
        .order('created_at', ascending: false);

    return data.map<WargaModel>((item) {
      return WargaModel.fromMap(item);
    }).toList();
  }
}
