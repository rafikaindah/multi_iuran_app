//model admin
class AdminModel {
  final String id;
  final String nama;
  final String email;
  final String userId;

  // fungsi konstruktor untuk membuat dan mengisi data admin
  AdminModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.userId,
  });

  //mengubah data dari bentuk Map (dari database) menjadi objek admin
  factory AdminModel.fromMap(Map<String, dynamic> data) {
    return AdminModel(
      id: data['id'],
      nama: data['nama'],
      email: data['email'],
      userId: data['user_id'],
    );
  }
}
