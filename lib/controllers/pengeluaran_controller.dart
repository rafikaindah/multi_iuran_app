import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pengeluaran_model.dart';

class PengeluaranController {
  final supabase = Supabase.instance.client;

  //tambah pengeluaran
  Future<void> tambahPengeluaran({
    required String iuranId,
    required int nominal,
    required String tanggal,
    required String keterangan,
    String? buktiFoto,
  }) async {
    await supabase.from('pengeluaran').insert({
      'iuran_id': iuranId,
      'nominal': nominal,
      'tanggal': tanggal,
      'keterangan': keterangan,
      'bukti_foto': buktiFoto,
    });
  }

  //mengambil data pengeluaran
  Future<List<PengeluaranModel>> getPengeluaran(String iuranId) async {
    final data = await supabase
        .from('pengeluaran')
        .select()
        .eq('iuran_id', iuranId)
        .order('created_at', ascending: false);

    return data.map<PengeluaranModel>((item) {
      return PengeluaranModel.fromMap(item);
    }).toList();
  }
}
