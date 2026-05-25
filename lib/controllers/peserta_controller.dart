import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/peserta_model.dart';

class PesertaController {
  final supabase = Supabase.instance.client;

  //mengambil peserta berdasarkan iuran
  Future<List<PesertaModel>> getPeserta(String iuranId) async {
    final data = await supabase
        .from('peserta')
        .select('''
          id,
          status,

          warga (
            id,
            nama,
            alamat,
            no_hp
          ),

          iuran (
            id,
            nama_iuran
          )
        ''')
        .eq('iuran_id', iuranId)
        .order('created_at', ascending: false);

    return data.map<PesertaModel>((item) {
      return PesertaModel.fromMap(item);
    }).toList();
  }

  //mengambil warga aktif
  Future<List<Map<String, dynamic>>> getWargaAktif() async {
    final data = await supabase
        .from('warga')
        .select()
        .eq('status', 'aktif')
        .order('nama');

    return List<Map<String, dynamic>>.from(data);
  }

  //mengambil riwayat pembayaran peserta
  Future<List<Map<String, dynamic>>> getRiwayatPembayaran(
    String pesertaId,
  ) async {
    final data = await supabase
        .from('pembayaran')
        .select()
        .eq('peserta_id', pesertaId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  //tambah peserta
  Future<void> tambahPeserta({
    required String wargaId,
    required String iuranId,
  }) async {
    await supabase.from('peserta').insert({
      'warga_id': wargaId,
      'iuran_id': iuranId,
      'status': 'aktif',
    });
  }

  //mengubah status peserta
  Future<void> updateStatus({
    required String id,
    required String status,
  }) async {
    await supabase.from('peserta').update({'status': status}).eq('id', id);
  }
}
