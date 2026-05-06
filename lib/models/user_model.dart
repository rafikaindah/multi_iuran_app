// Model untuk data pengguna
class UserModel {
  final String id;
  final String email;
  final String role;

  // Fungsi konstruktor untuk membuat dan mengisi data user
  UserModel({required this.id, required this.email, required this.role});

  // Factory method untuk mengubah data dari bentuk Map (dari database) menjadi objek user
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(id: data['id'], email: data['email'], role: data['role']);
  }
}
