import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pembayaran_model.dart';

class PembayaranController {
  final supabase = Supabase.instance.client;

  //ambil peserta aktif berdasarkan iuran
  Future<List<Map<String, dynamic>>> getPesertaAktif(String iuranId) async {
    final data = await supabase
        .from('peserta')
        .select('''
        id,
        status,
        warga:warga_id (
          nama,
          status
        )
      ''')
        .eq('iuran_id', iuranId)
        .eq('status', 'aktif');

    final pesertaAktif =
        data.where((item) => item['warga']['status'] == 'aktif').toList();

    return List<Map<String, dynamic>>.from(pesertaAktif);
  }

  //tambah pembayaran
  Future<void> tambahPembayaran({
    required String pesertaId,
    required String iuranId,
    required int nominal,
    required String tanggal,
    required List<String> periodeBayar,
  }) async {
    await supabase.from('pembayaran').insert({
      'peserta_id': pesertaId,
      'iuran_id': iuranId,
      'nominal': nominal,
      'tanggal': tanggal,
      'periode_bayar': periodeBayar,
      'status': 'selesai',
    });
  }

  //ambil data pembayaran
  Future<List<PembayaranModel>> getPembayaran(String iuranId) async {
    final data = await supabase
        .from('pembayaran')
        .select('''
          *,
          peserta:peserta_id (
            warga:warga_id (
              nama
            )
          )
        ''')
        .eq('iuran_id', iuranId)
        .order('created_at', ascending: false);

    return data.map<PembayaranModel>((item) {
      return PembayaranModel.fromMap(item);
    }).toList();
  }

  //cek periode yang sudah dibayar
  Future<List<String>> getPeriodeSudahDibayar({
    required String pesertaId,
    required String iuranId,
  }) async {
    final data = await supabase
        .from('pembayaran')
        .select('periode_bayar')
        .eq('peserta_id', pesertaId)
        .eq('iuran_id', iuranId);

    List<String> result = [];

    //mengambil semua periode yang sudah dibayar dan menggabungkannya menjadi 1 list
    for (var item in data) {
      if (item['periode_bayar'] != null) {
        result.addAll(List<String>.from(item['periode_bayar']));
      }
    }

    return result;
  }
}
