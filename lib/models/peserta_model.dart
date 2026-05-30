//model peserta
class PesertaModel {
  final String id;
  //relasi ke warga dan iuran
  final String wargaId;
  final String iuranId;
  //data warga yang diambil dari relasi untuk memudahkan tampilan
  final String namaWarga;
  final String alamat;
  final String noHp;
  final String namaIuran;

  final String status;
  final String statusWarga;

  //fungsi konstruktor untuk membuat dan mengisi data peserta
  PesertaModel({
    required this.id,
    required this.wargaId,
    required this.iuranId,
    required this.namaWarga,
    required this.alamat,
    required this.noHp,
    required this.namaIuran,
    required this.status,
    required this.statusWarga,
  });

  //factory method untuk mengubah data dari bentuk Map (dari database) menjadi objek peserta
  factory PesertaModel.fromMap(Map<String, dynamic> data) {
    return PesertaModel(
      id: data['id'],

      wargaId: data['warga']['id'],
      iuranId: data['iuran']['id'],

      namaWarga: data['warga']['nama'],
      alamat: data['warga']['alamat'],
      noHp: data['warga']['no_hp'],
      namaIuran: data['iuran']['nama_iuran'],

      status: data['status'],
      statusWarga: data['warga']['status'],
    );
  }
}
