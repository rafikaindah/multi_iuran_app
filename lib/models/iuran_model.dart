//model iuran
class IuranModel {
  final String id;
  final String namaIuran;

  // nominal dan periode bisa null
  final int? nominal;
  final String? periode;

  final String status;

  //fungsi konstruktor untuk membuat dan mengisi data iuran
  IuranModel({
    required this.id,
    required this.namaIuran,
    this.nominal,
    this.periode,
    required this.status,
  });

  //factory method untuk mengubah data dari bentuk Map (dari database) menjadi objek iuran
  factory IuranModel.fromMap(Map<String, dynamic> data) {
    return IuranModel(
      id: data['id'],
      namaIuran: data['nama_iuran'],
      nominal: data['nominal'],
      periode: data['periode'],
      status: data['status'],
    );
  }
}
