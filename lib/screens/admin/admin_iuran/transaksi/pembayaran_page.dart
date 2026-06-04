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

  // fungsi untuk mendapatkan nama bulan dari nomor bulan
  String getNamaBulan(int bulan) {
    switch (bulan) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'Mei';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Agu';
      case 9:
        return 'Sep';
      case 10:
        return 'Okt';
      case 11:
        return 'Nov';
      default:
        return 'Des';
    }
  }

  //generate periode berdasarkan periode iuran (mingguan atau bulanan)
  List<String> generatePeriode() {
    final now = DateTime.now();

    //mingguan
    if (widget.iuran['periode'] == 'Mingguan') {
      return [
        'Minggu 1 ${getNamaBulan(now.month)} ${now.year}',
        'Minggu 2 ${getNamaBulan(now.month)} ${now.year}',
        'Minggu 3 ${getNamaBulan(now.month)} ${now.year}',
        'Minggu 4 ${getNamaBulan(now.month)} ${now.year}',
      ];
    }

    //bulanan
    return [
      'Jan ${now.year}',
      'Feb ${now.year}',
      'Mar ${now.year}',
      'Apr ${now.year}',
      'Mei ${now.year}',
      'Jun ${now.year}',
      'Jul ${now.year}',
      'Agu ${now.year}',
      'Sep ${now.year}',
      'Okt ${now.year}',
      'Nov ${now.year}',
      'Des ${now.year}',
    ];
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
    final periodeList = generatePeriode();

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

                          periodeLunas = await pembayaranController
                              .getPeriodeSudahDibayar(
                                pesertaId: pesertaId!,
                                iuranId: widget.iuran['id'],
                              );
                          setModalState(() {});
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

                                await pembayaranController.tambahPembayaran(
                                  pesertaId: pesertaId!,
                                  iuranId: widget.iuran['id'],
                                  nominal: totalBayar,
                                  tanggal: tanggalController.text,
                                  periodeBayar: selectedPeriode,
                                );

                                Navigator.pop(context);

                                setState(() {});
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
