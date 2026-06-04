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
            no_hp,
            status
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
    // mengecek apakah warga sudah terdaftar pada iuran yang sama
    final sudahTerdaftar = await isPesertaTerdaftar(
      wargaId: wargaId,
      iuranId: iuranId,
    );
    // jika sudah terdaftar tampilkan error
    if (sudahTerdaftar) {
      throw Exception("Warga sudah terdaftar pada iuran ini");
    }
    // simpan peserta baru
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

  //menghitung status pembayaran peserta
  Future<Map<String, dynamic>> getStatusPembayaran({
    required String pesertaId,
    required Map<String, dynamic> iuran,
  }) async {
    //ambil pembayaran peserta
    final data = await supabase
        .from('pembayaran')
        .select('periode_bayar')
        .eq('peserta_id', pesertaId);

    //gabungkan semua periode yang sudah dibayar
    List<String> periodeBayar = [];

    for (var item in data) {
      final list = List<String>.from(item['periode_bayar'] ?? []);
      periodeBayar.addAll(list);
    }
    //hitung total periode yang seharusnya sudah dibayar
    final now = DateTime.now();
    int totalPeriodeSeharusnya = 0;

    //jika mingguan adalah 4 minggu dalam 1 bulan
    if (iuran['periode'] == 'Mingguan') {
      totalPeriodeSeharusnya = 4;
    }
    //jika bulanan adalah bulan berjalan
    else {
      totalPeriodeSeharusnya = now.month;
    }
    final totalSudahBayar = periodeBayar.toSet().length;
    final tunggakan = totalPeriodeSeharusnya - totalSudahBayar;

    return {
      'status': tunggakan <= 0 ? 'Lunas' : 'Menunggak',
      'jumlah_tunggakan': tunggakan <= 0 ? 0 : tunggakan,
    };
  }

  //mengambil peserta aktif berdasarkan iuran
  Future<List<PesertaModel>> getPesertaAktif(String iuranId) async {
    final data = await supabase
        .from('peserta')
        .select('''
        id,
        status,

        warga (
          id,
          nama,
          alamat,
          no_hp,
          status
        ),

        iuran (
          id,
          nama_iuran
        )
      ''')
        .eq('iuran_id', iuranId)
        .eq('status', 'aktif')
        .order('created_at', ascending: false);

    return data.map<PesertaModel>((item) {
      return PesertaModel.fromMap(item);
    }).toList();
  }

  // mengecek apakah warga sudah terdaftar pada iuran yang sama
  Future<bool> isPesertaTerdaftar({
    required String wargaId,
    required String iuranId,
  }) async {
    final data = await supabase
        .from('peserta')
        .select()
        .eq('warga_id', wargaId)
        .eq('iuran_id', iuranId);

    return data.isNotEmpty;
  }
}
