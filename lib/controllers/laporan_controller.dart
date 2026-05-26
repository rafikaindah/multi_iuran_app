import 'package:supabase_flutter/supabase_flutter.dart';

class LaporanController {
  final supabase = Supabase.instance.client;

  // fungsi untuk menghitung total pembayaran per bulan
  Future<int> totalPembayaran({
    required String iuranId,
    required int bulan,
    required int tahun,
  }) async {
    final data = await supabase
        .from('pembayaran')
        .select('nominal, tanggal')
        .eq('iuran_id', iuranId);

    int total = 0;

    for (var item in data) {
      final date = DateTime.parse(item['tanggal']);

      if (date.month == bulan && date.year == tahun) {
        total += (item['nominal'] ?? 0) as int;
      }
    }

    return total;
  }

  // fungsi untuk menghitung total pemasukan per bulan
  Future<int> totalPemasukan({
    required String iuranId,
    required int bulan,
    required int tahun,
  }) async {
    final data = await supabase
        .from('pemasukan')
        .select('nominal, tanggal')
        .eq('iuran_id', iuranId);

    int total = 0;

    for (var item in data) {
      final date = DateTime.parse(item['tanggal']);

      if (date.month == bulan && date.year == tahun) {
        total += (item['nominal'] ?? 0) as int;
      }
    }

    return total;
  }

  // fungsi untuk menghitung total pengeluaran per bulan
  Future<int> totalPengeluaran({
    required String iuranId,
    required int bulan,
    required int tahun,
  }) async {
    final data = await supabase
        .from('pengeluaran')
        .select('nominal, tanggal')
        .eq('iuran_id', iuranId);

    int total = 0;

    for (var item in data) {
      final date = DateTime.parse(item['tanggal']);

      if (date.month == bulan && date.year == tahun) {
        total += (item['nominal'] ?? 0) as int;
      }
    }

    return total;
  }

  // fungsi untuk mengambil saldo sebelumnya sebelum bulan dan tahun yang dipilih
  Future<int> saldoSebelumnya({
    required String iuranId,
    required int bulan,
    required int tahun,
  }) async {
    final pembayaran = await supabase
        .from('pembayaran')
        .select('nominal, tanggal')
        .eq('iuran_id', iuranId);

    final pemasukan = await supabase
        .from('pemasukan')
        .select('nominal, tanggal')
        .eq('iuran_id', iuranId);

    final pengeluaran = await supabase
        .from('pengeluaran')
        .select('nominal, tanggal')
        .eq('iuran_id', iuranId);

    int totalMasuk = 0;

    int totalKeluar = 0;

    // menghitung total pembayaran, pemasukan dan pengeluaran sebelum bulan dan tahun yang dipilih
    for (var item in pembayaran) {
      final date = DateTime.parse(item['tanggal']);

      if (date.year < tahun || (date.year == tahun && date.month < bulan)) {
        totalMasuk += (item['nominal'] ?? 0) as int;
      }
    }

    for (var item in pemasukan) {
      final date = DateTime.parse(item['tanggal']);

      if (date.year < tahun || (date.year == tahun && date.month < bulan)) {
        totalMasuk += (item['nominal'] ?? 0) as int;
      }
    }

    for (var item in pengeluaran) {
      final date = DateTime.parse(item['tanggal']);

      if (date.year < tahun || (date.year == tahun && date.month < bulan)) {
        totalKeluar += (item['nominal'] ?? 0) as int;
      }
    }

    return totalMasuk - totalKeluar;
  }

  // fungsi untuk mendapatkan riwayat transaksi
  Future<List<Map<String, dynamic>>> getRiwayatTransaksi({
    required String iuranId,
    required int bulan,
    required int tahun,
  }) async {
    final pembayaran = await supabase
        .from('pembayaran')
        .select()
        .eq('iuran_id', iuranId);

    final pemasukan = await supabase
        .from('pemasukan')
        .select()
        .eq('iuran_id', iuranId);

    final pengeluaran = await supabase
        .from('pengeluaran')
        .select()
        .eq('iuran_id', iuranId);

    List<Map<String, dynamic>> riwayat = [];

    // fungsi untuk menggabungkan pembayaran berdasarkan tanggal
    Map<String, int> pembayaranGabung = {};

    for (var item in pembayaran) {
      final tanggal = item['tanggal'];

      final date = DateTime.parse(tanggal);

      if (date.month != bulan || date.year != tahun) {
        continue;
      }

      final nominal = item['nominal'] ?? 0;

      if (pembayaranGabung.containsKey(tanggal)) {
        pembayaranGabung[tanggal] = pembayaranGabung[tanggal]! + nominal as int;
      } else {
        pembayaranGabung[tanggal] = nominal as int;
      }
    }

    pembayaranGabung.forEach((tanggal, total) {
      riwayat.add({
        'jenis': 'Pembayaran',
        'nominal': total,
        'tanggal': tanggal,
        'keterangan': 'Pembayaran peserta',
        'bukti': null,
      });
    });

    // menambahkan data pemasukan dan pengeluaran ke riwayat transaksi
    for (var item in pemasukan) {
      final date = DateTime.parse(item['tanggal']);

      if (date.month != bulan || date.year != tahun) {
        continue;
      }

      riwayat.add({
        'jenis': 'Pemasukan',
        'nominal': item['nominal'],
        'tanggal': item['tanggal'],
        'keterangan': item['keterangan'] ?? '-',
        'bukti': item['bukti_foto'],
      });
    }

    for (var item in pengeluaran) {
      final date = DateTime.parse(item['tanggal']);

      if (date.month != bulan || date.year != tahun) {
        continue;
      }

      riwayat.add({
        'jenis': 'Pengeluaran',
        'nominal': item['nominal'],
        'tanggal': item['tanggal'],
        'keterangan': item['keterangan'] ?? '-',
        'bukti': item['bukti_foto'],
      });
    }

    // urutkan data terbaru
    riwayat.sort((a, b) {
      return b['tanggal'].compareTo(a['tanggal']);
    });

    return riwayat;
  }
}
