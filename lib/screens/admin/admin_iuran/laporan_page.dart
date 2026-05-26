import 'package:flutter/material.dart';
import '../../../../controllers/laporan_controller.dart';

//halaman laporan admin iuran
class LaporanPage extends StatefulWidget {
  final Map<String, dynamic> iuran;

  const LaporanPage({super.key, required this.iuran});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

// state untuk halaman laporan admin iuran
class _LaporanPageState extends State<LaporanPage> {
  final laporanController = LaporanController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Laporan ${widget.iuran['nama_iuran']}")),
      // mengambil data laporan berdasarkan bulan dan tahun yang dipilih
      body: FutureBuilder(
        future: Future.wait([
          laporanController.totalPembayaran(
            iuranId: widget.iuran['id'],
            bulan: selectedBulan,
            tahun: selectedTahun,
          ),

          laporanController.totalPemasukan(
            iuranId: widget.iuran['id'],
            bulan: selectedBulan,
            tahun: selectedTahun,
          ),

          laporanController.totalPengeluaran(
            iuranId: widget.iuran['id'],
            bulan: selectedBulan,
            tahun: selectedTahun,
          ),

          laporanController.saldoSebelumnya(
            iuranId: widget.iuran['id'],
            bulan: selectedBulan,
            tahun: selectedTahun,
          ),

          laporanController.getRiwayatTransaksi(
            iuranId: widget.iuran['id'],
            bulan: selectedBulan,
            tahun: selectedTahun,
          ),
        ]),
        // mengolah data laporan
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // jika ada data transaksi
          final totalPembayaran = snapshot.data![0] as int;
          final totalPemasukan = snapshot.data![1] as int;
          final totalPengeluaran = snapshot.data![2] as int;
          final saldoSebelumnya = snapshot.data![3] as int;
          final riwayat = snapshot.data![4] as List<Map<String, dynamic>>;

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
                //filter bulan tahun
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedBulan,

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

                        decoration: const InputDecoration(labelText: "Bulan"),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedTahun,

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

                        decoration: const InputDecoration(labelText: "Tahun"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                //jika tidak ada data
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

                //jika ada data
                if (!tidakAdaData) ...[
                  const Text(
                    "Ringkasan Laporan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          trailing: Text(
                            "Rp $saldoAkhir",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Riwayat Transaksi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
