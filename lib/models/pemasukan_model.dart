// model pemasukan
class PemasukanModel {
  final String id;
  final String iuranId;
  final int nominal;
  final String tanggal;
  final String keterangan;
  final String? buktiFoto;

  // fungsi konstruktor untuk membuat dan mengisi data pemasukan
  PemasukanModel({
    required this.id,
    required this.iuranId,
    required this.nominal,
    required this.tanggal,
    required this.keterangan,
    this.buktiFoto,
  });

  // factory method untuk mengubah data dari bentuk Map (dari database) menjadi objek pemasukan
  factory PemasukanModel.fromMap(Map<String, dynamic> data) {
    return PemasukanModel(
      id: data['id'],
      iuranId: data['iuran_id'],
      nominal: data['nominal'] ?? 0,
      tanggal: data['tanggal'] ?? '',
      keterangan: data['keterangan'] ?? '',
      buktiFoto: data['bukti_foto'],
    );
  }
}
