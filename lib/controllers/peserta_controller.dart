import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/peserta_model.dart';

class PesertaController {
  final supabase = Supabase.instance.client;

  // helper: minggu ke berapa dalam bulan (1–4)
  int _mingguDari(DateTime d) => ((d.day - 1) ~/ 7) + 1;

  // helper: hitung total periode yang seharusnya sudah dibayar
  int _hitungPeriode({
    required String periode,
    required DateTime pesertaCreatedAt,
  }) {
    final now = DateTime.now();

    if (periode == 'Mingguan') {
      // Selisih bulan antara bulan daftar dan bulan sekarang
      final selisihBulan =
          (now.year - pesertaCreatedAt.year) * 12 +
          (now.month - pesertaCreatedAt.month);

      // Minggu yang sudah lewat di bulan ini (minggu sekarang belum dihitung)
      final mingguSudahLewatBulanIni = _mingguDari(now) - 1;

      // Minggu di bulan pertama sebelum peserta daftar (diabaikan)
      final mingguAwalDiabaikan = _mingguDari(pesertaCreatedAt) - 1;

      final total =
          selisihBulan * 4 + mingguSudahLewatBulanIni - mingguAwalDiabaikan;

      return total < 0 ? 0 : total;
    } else {
      // Bulanan: bulan sekarang belum dihitung, tunggakan muncul bulan depan
      final total =
          (now.year - pesertaCreatedAt.year) * 12 +
          (now.month - pesertaCreatedAt.month - 1);

      return total < 0 ? 0 : total;
    }
  }

  Future<List<PesertaModel>> getPeserta(String iuranId) async {
    final data = await supabase
        .from('peserta')
        .select('''
          id,
          status,
          created_at,
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
    required DateTime pesertaCreatedAt,
  }) async {
    //ambil pembayaran peserta
    final pesertaData =
        await supabase
            .from('peserta')
            .select('''
            status,

            warga (
              status
            )
          ''')
            .eq('id', pesertaId)
            .single();

    final statusPeserta = pesertaData['status'];
    final statusWarga = pesertaData['warga']['status'];
    final statusIuran = iuran['status'];

    // jika warga / peserta / iuran tidak aktif
    if (statusPeserta != 'aktif' ||
        statusWarga != 'aktif' ||
        statusIuran != 'aktif') {
      return {'status': 'Dinonaktifkan', 'jumlah_tunggakan': 0};
    }

    // ambil pembayaran peserta
    final data = await supabase
        .from('pembayaran')
        .select('periode_bayar')
        .eq('peserta_id', pesertaId);

    final periodeBayar = <String>{};
    for (var item in data) {
      periodeBayar.addAll(List<String>.from(item['periode_bayar'] ?? []));
    }

    //hitung periode seharusnya vs sudah bayar
    final totalSeharusnya = _hitungPeriode(
      periode: iuran['periode'],
      pesertaCreatedAt: pesertaCreatedAt,
    );

    final tunggakan = totalSeharusnya - periodeBayar.length;

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
          created_at,
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
