import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // pdf widgets dengan alias pw
import 'package:printing/printing.dart';

class PdfController {
  // membuat laporan pdf berdasarkan data yang diberikan
  Future<Uint8List> generateLaporanPdf({
    required String namaIuran,
    required int bulan,
    required int tahun,
    required int saldoSebelumnya,
    required int totalPembayaran,
    required int totalPemasukan,
    required int totalPengeluaran,
    required int saldoAkhir,
    required List<Map<String, dynamic>> riwayat,
  }) async {
    final pdf = pw.Document(); // membuat dokumen pdf baru

    final namaBulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    // mengurutkan transaksi dari tanggal terlama ke terbaru
    riwayat.sort((a, b) {
      final tanggalA = DateTime.parse(a['tanggal']);
      final tanggalB = DateTime.parse(b['tanggal']);

      return tanggalA.compareTo(tanggalB);
    });

    // menambahkan halaman dan isi laporan ke dokumen pdf
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,

        build: (context) {
          return [
            // judul
            pw.Center(
              child: pw.Text(
                "LAPORAN IURAN",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Divider(),

            pw.SizedBox(height: 10),

            // info laporan
            pw.Text(
              "Jenis Iuran = $namaIuran",
              style: const pw.TextStyle(fontSize: 14),
            ),

            pw.SizedBox(height: 5),

            pw.Text(
              "Periode = ${namaBulan[bulan]} $tahun",
              style: const pw.TextStyle(fontSize: 14),
            ),

            pw.SizedBox(height: 20),

            // ringkasan laporan
            pw.Container(
              width: double.infinity,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
              ),

              child: pw.Column(
                children: [
                  // header
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(8),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      "RINGKASAN LAPORAN",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey),

                    children: [
                      tableRow("Saldo Sebelumnya", saldoSebelumnya),
                      tableRow("Total Pembayaran", totalPembayaran),
                      tableRow("Total Pemasukan", totalPemasukan),
                      tableRow("Total Pengeluaran", totalPengeluaran),
                      tableRow("Saldo", saldoAkhir),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 25),

            // rincian transaksi
            pw.Text(
              "RINCIAN TRANSAKSI",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 10),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey),

              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FixedColumnWidth(70),
                2: const pw.FlexColumnWidth(),
                3: const pw.FixedColumnWidth(60),
                4: const pw.FixedColumnWidth(60),
              },

              children: [
                // header tabel
                pw.TableRow(
                  children: [
                    tableHeader("No"),
                    tableHeader("Tanggal"),
                    tableHeader("Keterangan"),
                    tableHeader("Masuk"),
                    tableHeader("Keluar"),
                  ],
                ),

                // isi tabel
                ...List.generate(riwayat.length, (index) {
                  final item = riwayat[index];
                  final jenis = item['jenis'];
                  final nominal = item['nominal'];
                  String masuk = "-";
                  String keluar = "-";

                  // pembayaran dan pemasukan = masuk
                  if (jenis == 'Pembayaran' || jenis == 'Pemasukan') {
                    masuk = formatRupiah(nominal);
                  }

                  // pengeluaran = keluar
                  if (jenis == 'Pengeluaran') {
                    keluar = formatRupiah(nominal);
                  }

                  return pw.TableRow(
                    children: [
                      tableCell("${index + 1}"), // nomor urut
                      tableCell(item['tanggal']),
                      tableCell(item['keterangan']),
                      tableCell(masuk),
                      tableCell(keluar),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  //  menampilkan preview pdf
  Future<void> previewPdf(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  // membuat baris tabel untuk ringkasan laporan
  pw.TableRow tableRow(String title, int nominal) {
    return pw.TableRow(
      children: [tableCell(title), tableCell(formatRupiah(nominal))],
    );
  }

  // membuat header/judul kolom untuk tabel rincian transaksi
  pw.Widget tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),

      child: pw.Text(
        text,

        textAlign: pw.TextAlign.center,

        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      ),
    );
  }

  // membuat isi tabel
  pw.Widget tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),

      child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
    );
  }

  // format rupiah
  String formatRupiah(int nominal) {
    return nominal.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),

      (match) => '.',
    );
  }
}
