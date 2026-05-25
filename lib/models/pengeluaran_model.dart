//model pengeluaran
class PengeluaranModel {
  final String id;
  final String iuranId;
  final int nominal;
  final String tanggal;
  final String keterangan;

  //fungsi konstruktor untuk membuat dan mengisi data pengeluaran
  PengeluaranModel({
    required this.id,
    required this.iuranId,
    required this.nominal,
    required this.tanggal,
    required this.keterangan,
  });

  //factory method untuk mengubah data dari bentuk Map (dari database) menjadi objek pengeluaran
  factory PengeluaranModel.fromMap(Map<String, dynamic> data) {
    return PengeluaranModel(
      id: data['id'],
      iuranId: data['iuran_id'],
      nominal: data['nominal'] ?? 0,
      tanggal: data['tanggal'] ?? '',
      keterangan: data['keterangan'] ?? '',
    );
  }
}
