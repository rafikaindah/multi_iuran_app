import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pemasukan_model.dart';

class PemasukanController {
  final supabase = Supabase.instance.client;

  //tambah pemasukan
  Future<void> tambahPemasukan({
    required String iuranId,
    required int nominal,
    required String tanggal,
    required String keterangan,
    String? buktiFoto,
  }) async {
    await supabase.from('pemasukan').insert({
      'iuran_id': iuranId,
      'nominal': nominal,
      'tanggal': tanggal,
      'keterangan': keterangan,
      'bukti_foto': buktiFoto,
    });
  }

  //mengambil data pemasukan
  Future<List<PemasukanModel>> getPemasukan(String iuranId) async {
    final data = await supabase
        .from('pemasukan')
        .select()
        .eq('iuran_id', iuranId)
        .order('created_at', ascending: false);

    return data.map<PemasukanModel>((item) {
      return PemasukanModel.fromMap(item);
    }).toList();
  }
}
