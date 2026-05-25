//model pembayaran
class PembayaranModel {
  final String id;
  final String pesertaId;
  final String iuranId;
  final int nominal;
  final String tanggal;
  final List<String> periodeBayar;
  final String? namaPeserta;

  //fungsi konstruktor untuk membuat dan mengisi data pembayaran
  PembayaranModel({
    required this.id,
    required this.pesertaId,
    required this.iuranId,
    required this.nominal,
    required this.tanggal,
    required this.periodeBayar,
    this.namaPeserta,
  });

  //factory method untuk mengubah data dari bentuk Map (dari database) menjadi objek pembayaran
  factory PembayaranModel.fromMap(Map<String, dynamic> data) {
    return PembayaranModel(
      id: data['id'],
      pesertaId: data['peserta_id'],
      iuranId: data['iuran_id'],
      nominal: data['nominal'] ?? 0,
      tanggal: data['tanggal'] ?? '',
      periodeBayar:
          data['periode_bayar'] != null
              ? List<String>.from(data['periode_bayar'])
              : [],
      namaPeserta: data['peserta']?['warga']?['nama'],
    );
  }
}
