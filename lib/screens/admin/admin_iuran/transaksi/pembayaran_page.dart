import 'package:flutter/material.dart';
import '../../../../controllers/pembayaran_controller.dart';
import '../../../../models/pembayaran_model.dart';

//halaman pembayaran admin iuran
class PembayaranPage extends StatefulWidget {
  final Map<String, dynamic> iuran;

  const PembayaranPage({super.key, required this.iuran});

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

// state untuk halaman pembayaran
class _PembayaranPageState extends State<PembayaranPage> {
  final pembayaranController = PembayaranController();

  // warna utama aplikasi
  final Color primaryColor = const Color.fromARGB(255, 100, 161, 102);

  // fungsi untuk mendapatkan nama bulan
  String getNamaBulan(int bulan) {
    const namaBulan = [
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
    return namaBulan[bulan];
  }

  // periode yang harus dibayar (dihitung dari bulan peserta terdaftar sampai bulan saat ini)
  List<String> generateSemuaPeriode({required DateTime pesertaCreatedAt}) {
    final now = DateTime.now(); //batas akhir perhitungan

    final String periode =
        widget.iuran['periode']?.toString() ?? ''; // jenis periode iuran
    List<String> periodeList = []; // hasil periode

    //periode mingguan
    if (periode == 'Mingguan') {
      // mulai dari bulan peserta daftar, berhenti di bulan ini
      DateTime cursor = DateTime(pesertaCreatedAt.year, pesertaCreatedAt.month);
      final DateTime batasAkhir = DateTime(now.year, now.month);

      while (!cursor.isAfter(batasAkhir)) {
        // bulan pertama: hitung mulai dari minggu keberapa peserta daftar
        // daftar tanggal 10 → (10-1)~/7 + 1 = minggu ke-2
        int mingguMulai = 1;
        if (cursor.year == pesertaCreatedAt.year &&
            cursor.month == pesertaCreatedAt.month) {
          mingguMulai = ((pesertaCreatedAt.day - 1) ~/ 7) + 1;
        }

        // tambahkan setiap minggu pada bulan ini ke list
        for (int minggu = mingguMulai; minggu <= 4; minggu++) {
          periodeList.add(
            'Minggu $minggu ${getNamaBulan(cursor.month)} ${cursor.year}',
          );
        }

        cursor = DateTime(
          cursor.year,
          cursor.month + 1,
        ); // maju ke bulan berikutnya
      }

      //periode bulanan
    } else {
      // mulai dari bulan peserta daftar, berhenti di bulan ini
      DateTime cursor = DateTime(pesertaCreatedAt.year, pesertaCreatedAt.month);
      final DateTime batasAkhir = DateTime(now.year, now.month);
      while (!cursor.isAfter(batasAkhir)) {
        periodeList.add(
          '${getNamaBulan(cursor.month)} ${cursor.year}',
        ); // tambahkan bulan ke list
        cursor = DateTime(
          cursor.year,
          cursor.month + 1,
        ); // maju ke bulan berikutnya
      }
    }

    return periodeList;
  }

  //dialog tambah pembayaran
  Future<void> tambahPembayaranDialog() async {
    String? pesertaId;
    final tanggalController = TextEditingController(
      text: DateTime.now().toString().split(' ')[0],
    );

    final pesertaList = await pembayaranController.getPesertaAktif(
      widget.iuran['id'],
    );

    List<String> selectedPeriode = [];
    List<String> periodeLunas = [];
    int totalBayar = 0; //
    final int nominalIuran =
        int.tryParse(widget.iuran['nominal'].toString()) ?? 0;
    // checkbox periode baru muncul setelah peserta dipilih
    List<String> periodeList = [];

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),

              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Center(
                        child: Text(
                          "Tambah Pembayaran",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // pilih peserta
                      DropdownButtonFormField<String>(
                        value: pesertaId,

                        decoration: InputDecoration(
                          labelText: "Pilih Peserta",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        items:
                            pesertaList.map<DropdownMenuItem<String>>((
                              peserta,
                            ) {
                              return DropdownMenuItem<String>(
                                value: peserta['id'].toString(),
                                child: Text(
                                  peserta['warga']['nama'].toString(),
                                ),
                              );
                            }).toList(),

                        onChanged: (value) async {
                          pesertaId = value;

                          // ambil periode yang sudah dibayar peserta yang dipilih
                          periodeLunas = await pembayaranController
                              .getPeriodeSudahDibayar(
                                pesertaId: pesertaId!,
                                iuranId: widget.iuran['id'],
                              );

                          // reset pilihan saat ganti peserta
                          selectedPeriode.clear();
                          totalBayar = 0;

                          // ambil created_at peserta yang dipilih
                          final selectedPeserta = pesertaList.firstWhere(
                            (p) => p['id'].toString() == pesertaId,
                          );
                          final pesertaCreatedAtRaw =
                              selectedPeserta['created_at']?.toString();
                          final pesertaCreatedAt =
                              pesertaCreatedAtRaw != null
                                  ? DateTime.tryParse(pesertaCreatedAtRaw) ??
                                      DateTime.now()
                                  : DateTime.now();

                          // gunakan created_at peserta sebagai titik awal periode
                          final semuaPeriode = generateSemuaPeriode(
                            pesertaCreatedAt: pesertaCreatedAt,
                          );
                          // periode yang belum dibayar peserta ini (tunggakan)
                          final periodeBelumdibayar =
                              semuaPeriode
                                  .where((p) => !periodeLunas.contains(p))
                                  .toList();

                          // periode default: bulan ini + 5 bulan ke depan
                          final String periodeIuran =
                              widget.iuran['periode']?.toString() ?? '';
                          List<String> periodeDefault = [];

                          if (periodeIuran == 'Mingguan') {
                            final now = DateTime.now();
                            periodeDefault = [
                              'Minggu 1 ${getNamaBulan(now.month)} ${now.year}',
                              'Minggu 2 ${getNamaBulan(now.month)} ${now.year}',
                              'Minggu 3 ${getNamaBulan(now.month)} ${now.year}',
                              'Minggu 4 ${getNamaBulan(now.month)} ${now.year}',
                            ];
                          } else {
                            final now = DateTime.now();

                            DateTime cursor = DateTime(now.year, now.month);

                            final DateTime batasAkhir = DateTime(
                              now.year,
                              now.month + 5,
                            );

                            while (!cursor.isAfter(batasAkhir)) {
                              periodeDefault.add(
                                '${getNamaBulan(cursor.month)} ${cursor.year}',
                              );

                              cursor = DateTime(cursor.year, cursor.month + 1);
                            }
                          }

                          // gabungkan tunggakan + periode default (hindari duplikat)
                          final gabungan = [
                            ...periodeBelumdibayar,
                            ...periodeDefault.where(
                              (p) => !periodeBelumdibayar.contains(p),
                            ),
                          ];

                          // urutkan sesuai urutan waktu
                          final referensi = [
                            ...semuaPeriode,
                            ...periodeDefault.where(
                              (p) => !semuaPeriode.contains(p),
                            ),
                          ];

                          gabungan.sort(
                            (a, b) => referensi
                                .indexOf(a)
                                .compareTo(referensi.indexOf(b)),
                          );

                          setModalState(() {
                            periodeList = gabungan;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // tanggal
                      TextField(
                        controller: tanggalController,
                        decoration: InputDecoration(
                          labelText: "Tanggal Pembayaran",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // total bayar
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Text(
                          "Nominal Bayar : Rp $totalBayar",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        "Pilih Periode Pembayaran",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // list periode
                      Column(
                        children:
                            periodeList.map((periode) {
                              final sudahBayar = periodeLunas.contains(periode);
                              return CheckboxListTile(
                                value:
                                    sudahBayar
                                        ? true
                                        : selectedPeriode.contains(periode),

                                title: Text(
                                  periode,
                                  style: TextStyle(
                                    fontWeight:
                                        sudahBayar
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                enabled: !sudahBayar,

                                onChanged: (value) {
                                  setModalState(() {
                                    if (value == true) {
                                      if (!selectedPeriode.contains(periode)) {
                                        selectedPeriode.add(periode);
                                      }
                                    } else {
                                      selectedPeriode.remove(periode);
                                    }

                                    totalBayar =
                                        selectedPeriode.length * nominalIuran;
                                  });
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 20),
                      // aksi untuk tombol simpan dan batal
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },

                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),

                              child: const Text("Batal"),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (pesertaId == null ||
                                    selectedPeriode.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Peserta dan periode wajib dipilih",
                                      ),
                                    ),
                                  );

                                  return;
                                }

                                try {
                                  await pembayaranController.tambahPembayaran(
                                    pesertaId: pesertaId!,
                                    iuranId: widget.iuran['id'],
                                    nominal: totalBayar,
                                    tanggal: tanggalController.text,
                                    periodeBayar: selectedPeriode,
                                  );

                                  Navigator.pop(context);

                                  setState(() {});
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceAll(
                                          'Exception: ',
                                          '',
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,

                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),

                              child: const Text("Simpan"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed:
            widget.iuran['status'] == 'aktif'
                ? tambahPembayaranDialog
                : null, // tombol tidak aktif jika iuran tidak aktif
        child: const Icon(Icons.add, color: Colors.white),
      ),
      // menampilkan list pembayaran
      body: FutureBuilder<List<PembayaranModel>>(
        future: pembayaranController.getPembayaran(widget.iuran['id']),

        builder: (context, snapshot) {
          //loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          //jika data kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Data pembayaran kosong",
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          //jika ada data pembayaran
          final pembayaranList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: pembayaranList.length,

            itemBuilder: (context, index) {
              final pembayaran = pembayaranList[index];
              // menampilkan card pembayaran
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
                      // nama peserta
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pembayaran.namaPeserta ?? '-',

                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // nominal
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Rp ${pembayaran.nominal}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // periode
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Expanded(
                            child: Text(
                              "Periode : ${pembayaran.periodeBayar.join(", ")}",

                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // tanggal
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Tanggal : ${pembayaran.tanggal}",

                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
