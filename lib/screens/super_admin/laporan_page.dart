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
      appBar: AppBar(title: const Text("Laporan")),
      // menampilkan loading jika data iuran belum dimuat, jika sudah tampilkan konten laporan
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
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // tombol export pdf
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: exportPdf,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text("Export PDF"),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // pilih jenis iuran
                        DropdownButtonFormField<String>(
                          value: selectedIuranId,

                          decoration: const InputDecoration(
                            labelText: "Pilih Jenis Iuran",
                            border: OutlineInputBorder(),
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
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: selectedBulan,

                                decoration: const InputDecoration(
                                  labelText: "Bulan",
                                  border: OutlineInputBorder(),
                                ),

                                items: List.generate(12, (index) {
                                  final bulan = index + 1;

                                  return DropdownMenuItem(
                                    value: bulan,
                                    child: Text(namaBulan[bulan]),
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

                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: selectedTahun,

                                decoration: const InputDecoration(
                                  labelText: "Tahun",
                                  border: OutlineInputBorder(),
                                ),

                                items: List.generate(5, (index) {
                                  final tahun = DateTime.now().year - 2 + index;

                                  return DropdownMenuItem(
                                    value: tahun,
                                    child: Text("$tahun"),
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

                        const SizedBox(height: 20),

                        // jika tidak ada data
                        if (tidakAdaData)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: Text(
                                "Tidak ada data transaksi pada bulan ini",
                                style: TextStyle(fontSize: 16),
                              ),
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

                          const SizedBox(height: 10),

                          Card(
                            child: Column(
                              children: [
                                ListTile(
                                  title: const Text("Saldo Bulan Sebelumnya"),
                                  trailing: Text("Rp $saldoSebelumnya"),
                                ),

                                const Divider(height: 1),

                                ListTile(
                                  title: const Text("Total Pembayaran"),
                                  trailing: Text("Rp $totalPembayaran"),
                                ),

                                const Divider(height: 1),

                                ListTile(
                                  title: const Text("Total Pemasukan"),
                                  trailing: Text("Rp $totalPemasukan"),
                                ),

                                const Divider(height: 1),

                                ListTile(
                                  title: const Text("Total Pengeluaran"),
                                  trailing: Text("Rp $totalPengeluaran"),
                                ),

                                const Divider(height: 1),

                                ListTile(
                                  title: const Text(
                                    "Saldo Akhir",

                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  trailing: Text(
                                    "Rp $saldoAkhir",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "Riwayat Transaksi",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          ...riwayat.map((item) {
                            return Card(
                              child: ListTile(
                                title: Text(item['jenis']),

                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text("Tanggal : ${item['tanggal']}"),
                                    Text(item['keterangan']),
                                  ],
                                ),

                                trailing: Text("Rp ${item['nominal']}"),
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
}
