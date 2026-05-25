import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageController {
  final supabase = Supabase.instance.client;

  //upload foto ke storage supabase
  Future<String> uploadFoto(File file) async {
    try {
      //nama file unik
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      //path di storage
      final filePath = 'uploads/$fileName';

      //upload file
      await supabase.storage.from('bukti-transaksi').upload(filePath, file);

      //ambil public url
      final imageUrl = supabase.storage
          .from('bukti-transaksi')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      throw Exception('Gagal upload foto: $e');
    }
  }
}
