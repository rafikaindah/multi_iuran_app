//model warga
class WargaModel {
  final String id;
  final String nama;
  final String alamat;
  final String noHp;
  final String status;

  //fungsi konstruktor untuk membuat dan mengisi data warga
  WargaModel({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.noHp,
    required this.status,
  });

  //factory method untuk mengubah data dari bentuk Map (dari database) menjadi objek warga
  factory WargaModel.fromMap(Map<String, dynamic> data) {
    return WargaModel(
      id: data['id'],
      nama: data['nama'],
      alamat: data['alamat'],
      noHp: data['no_hp'],
      status: data['status'],
    );
  }
}
