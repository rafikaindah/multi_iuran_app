import 'package:flutter/material.dart';
import '../../controllers/iuran_controller.dart';
import '../../controllers/laporan_controller.dart';
import '../../controllers/pdf_controller.dart';
import '../../models/iuran_model.dart';

// halaman laporan super admin
class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

// state untuk halaman laporan super admin
class _LaporanPageState extends State<LaporanPage> {
  final laporanController = LaporanController();

  final iuranController = IuranController();
  final pdfController = PdfController();

  // warna utama
  final primaryColor = const Color.fromARGB(255, 100, 161, 102);

  List<IuranModel> iuranList = [];
  String? selectedIuranId;
  String selectedNamaIuran = "";

  int selectedBulan = DateTime.now().month;
  int selectedTahun = DateTime.now().year;

  final List<String> namaBulan = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  // loading data iuran saat halaman pertama kali dibuka
  @override
  void initState() {
    super.initState();
    loadIuran();
  }

  // mengambil semua jenis iuran aktif
  Future<void> loadIuran() async {
    final data = await iuranController.getIuran();

    setState(() {
      iuranList = data;
      // set iuran pertama sebagai default yang dipilih
      if (data.isNotEmpty) {
        final firstIuran = data.first;
        selectedIuranId = firstIuran.id;
        selectedNamaIuran = firstIuran.namaIuran;
      }
    });
  }

  // export pdf
  Future<void> exportPdf() async {
    if (selectedIuranId == null) return;

    final totalPembayaran = await laporanController.totalPembayaran(
      iuranId: selectedIuranId!,
      bulan: selectedBulan,
      tahun: selectedTahun,
    );

    final totalPemasukan = await laporanController.totalPemasukan(
      iuranId: selectedIuranId!,
      bulan: selectedBulan,
      tahun: selectedTahun,
    );

    final totalPengeluaran = await laporanController.totalPengeluaran(
      iuranId: selectedIuranId!,
      bulan: selectedBulan,
      tahun: selectedTahun,
    );

    final saldoSebelumnya = await laporanController.saldoSebelumnya(
      iuranId: selectedIuranId!,
      bulan: selectedBulan,
      tahun: selectedTahun,
    );

    final riwayat = await laporanController.getRiwayatTransaksi(
      iuranId: selectedIuranId!,
      bulan: selectedBulan,
      tahun: selectedTahun,
    );

    final saldoAkhir =
        saldoSebelumnya + totalPembayaran + totalPemasukan - totalPengeluaran;

    final pdfBytes = await pdfController.generateLaporanPdf(
      namaIuran: selectedNamaIuran,
      bulan: selectedBulan,
      tahun: selectedTahun,
      saldoSebelumnya: saldoSebelumnya,
      totalPembayaran: totalPembayaran,
      totalPemasukan: totalPemasukan,
      totalPengeluaran: totalPengeluaran,
      saldoAkhir: saldoAkhir,
      riwayat: riwayat,
    );

    await pdfController.previewPdf(pdfBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        title: const Text("Laporan"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // menampilkan loading jika data iuran belum dimuat, jika sudah  tampilkan konten laporan
      body:
          selectedIuranId == null
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder(
                future: Future.wait([
                  laporanController.totalPembayaran(
                    iuranId: selectedIuranId!,
                    bulan: selectedBulan,
                    tahun: selectedTahun,
                  ),

                  laporanController.totalPemasukan(
                    iuranId: selectedIuranId!,
                    bulan: selectedBulan,
                    tahun: selectedTahun,
                  ),

                  laporanController.totalPengeluaran(
                    iuranId: selectedIuranId!,
                    bulan: selectedBulan,
                    tahun: selectedTahun,
                  ),

                  laporanController.saldoSebelumnya(
                    iuranId: selectedIuranId!,
                    bulan: selectedBulan,
                    tahun: selectedTahun,
                  ),

                  laporanController.getRiwayatTransaksi(
                    iuranId: selectedIuranId!,
                    bulan: selectedBulan,
                    tahun: selectedTahun,
                  ),
                ]),
                //mengolah data laporan
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  //jika ada data transaksi
                  final totalPembayaran = snapshot.data![0] as int;
                  final totalPemasukan = snapshot.data![1] as int;
                  final totalPengeluaran = snapshot.data![2] as int;
                  final saldoSebelumnya = snapshot.data![3] as int;
                  final riwayat =
                      snapshot.data![4] as List<Map<String, dynamic>>;

                  final saldoAkhir =
                      saldoSebelumnya +
                      totalPembayaran +
                      totalPemasukan -
                      totalPengeluaran;

                  //jika tidak ada transaksi
                  final tidakAdaData =
                      totalPembayaran == 0 &&
                      totalPemasukan == 0 &&
                      totalPengeluaran == 0;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // tombol export pdf
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: exportPdf,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,

                              padding: const EdgeInsets.symmetric(vertical: 15),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),

                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text(
                              "Export PDF",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // pilih jenis iuran
                        Container(
                          padding: const EdgeInsets.all(16),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Column(
                            children: [
                              DropdownButtonFormField<String>(
                                value: selectedIuranId,

                                decoration: InputDecoration(
                                  labelText: "Pilih Jenis Iuran",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),

                                items:
                                    iuranList.map((item) {
                                      return DropdownMenuItem<String>(
                                        value: item.id,
                                        child: Text(item.namaIuran),
                                      );
                                    }).toList(),

                                onChanged: (value) {
                                  final selected = iuranList.firstWhere(
                                    (item) => item.id == value,
                                  );

                                  setState(() {
                                    selectedIuranId = value;

                                    selectedNamaIuran = selected.namaIuran;
                                  });
                                },
                              ),

                              const SizedBox(height: 15),

                              // filter bulan tahun
                              Row(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: DropdownButtonFormField<int>(
                                      value: selectedBulan,
                                      isExpanded: true,

                                      decoration: InputDecoration(
                                        labelText: "Bulan",

                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 14,
                                            ),

                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),

                                      items: List.generate(12, (index) {
                                        final bulan = index + 1;

                                        return DropdownMenuItem(
                                          value: bulan,
                                          child: Text(
                                            namaBulan[bulan],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }),

                                      onChanged: (value) {
                                        setState(() {
                                          selectedBulan = value!;
                                        });
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Flexible(
                                    flex: 1,
                                    child: DropdownButtonFormField<int>(
                                      value: selectedTahun,
                                      isExpanded: true,

                                      decoration: InputDecoration(
                                        labelText: "Tahun",

                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 14,
                                            ),

                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),

                                      items: List.generate(5, (index) {
                                        final tahun =
                                            DateTime.now().year - 2 + index;

                                        return DropdownMenuItem(
                                          value: tahun,
                                          child: Text(
                                            "$tahun",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }),

                                      onChanged: (value) {
                                        setState(() {
                                          selectedTahun = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // jika tidak ada data
                        if (tidakAdaData)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(30),

                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),

                            child: const Column(
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 60,
                                  color: Colors.grey,
                                ),

                                SizedBox(height: 15),

                                Text(
                                  "Tidak ada data transaksi pada bulan ini",

                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // jika ada data
                        if (!tidakAdaData) ...[
                          const Text(
                            "Ringkasan Laporan",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),

                            child: Column(
                              children: [
                                laporanItem(
                                  "Saldo Bulan Sebelumnya",
                                  "Rp $saldoSebelumnya",
                                ),

                                divider(),

                                laporanItem(
                                  "Total Pembayaran",
                                  "Rp $totalPembayaran",
                                ),

                                divider(),

                                laporanItem(
                                  "Total Pemasukan",
                                  "Rp $totalPemasukan",
                                ),

                                divider(),

                                laporanItem(
                                  "Total Pengeluaran",
                                  "Rp $totalPengeluaran",
                                ),

                                divider(),

                                laporanItem(
                                  "Saldo Akhir",
                                  "Rp $saldoAkhir",
                                  isBold: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),

                          const Text(
                            "Riwayat Transaksi",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          ...riwayat.map((item) {
                            final isPengeluaran =
                                item['jenis'] == 'Pengeluaran';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),

                              child: Padding(
                                padding: const EdgeInsets.all(16),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,

                                            children: [
                                              Text(
                                                item['jenis'],

                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              const SizedBox(height: 4),

                                              Text(
                                                "Tanggal : ${item['tanggal']}",

                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      item['keterangan'],

                                      style: const TextStyle(fontSize: 14),
                                    ),

                                    const SizedBox(height: 14),

                                    Align(
                                      alignment: Alignment.centerRight,

                                      child: Text(
                                        "Rp ${item['nominal']}",

                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,

                                          color:
                                              isPengeluaran
                                                  ? Colors.red
                                                  : Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  );
                },
              ),
    );
  }

  // widget item laporan
  Widget laporanItem(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

      child: Row(
        children: [
          Expanded(
            child: Text(
              title,

              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Flexible(
            child: Text(
              value,

              textAlign: TextAlign.end,

              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,

                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // divider custom
  Widget divider() {
    return const Divider(height: 1);
  }
}
