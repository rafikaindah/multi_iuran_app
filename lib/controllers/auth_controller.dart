import 'package:supabase_flutter/supabase_flutter.dart';

// Controller untuk logika autentikasi
class AuthController {
  final supabase = Supabase.instance.client;

  // Fungsi login yang mengembalikan role pengguna jika berhasil,null jika gagal
  Future<String?> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // Jika login berhasil, ambil data pengguna untuk mendapatkan role
      final user = response.user;
      if (user == null) return null;
      // Ambil role pengguna dari tabel 'users' berdasarkan user ID
      final data =
          await supabase
              .from('users')
              .select('role')
              .eq('id', user.id)
              .single();
      // Kembalikan role pengguna
      return data['role'];
    } catch (e) {
      // Jika terjadi error saat login, cetak error di console dan kembalikan null
      print("ERROR LOGIN: $e");
      return null;
    }
  }
}
