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
            return AlertDialog(
              title: const Text("Form Tambah Pembayaran"),
              // isi dialog untuk pilih peserta, tanggal, dan periode bayar
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    DropdownButtonFormField<String>(
                      value: pesertaId,
                      items:
                          pesertaList.map<DropdownMenuItem<String>>((peserta) {
                            return DropdownMenuItem<String>(
                              value: peserta['id'].toString(),
                              child: Text(peserta['warga']['nama'].toString()),
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

                      decoration: const InputDecoration(
                        labelText: "Pilih Peserta",
                      ),
                    ),

                    TextField(
                      controller: tanggalController,
                      decoration: const InputDecoration(
                        labelText: "Tanggal Pembayaran",
                      ),
                    ),

                    Text(
                      "Nominal Bayar : Rp $totalBayar",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const Text("Pilih periode yang dibayar"),
                    // menampilkan checkbox untuk setiap periode, jika sudah lunas maka checkbox tidak bisa dipilih
                    Column(
                      children:
                          periodeList.map((periode) {
                            final sudahBayar = periodeLunas.contains(periode);
                            return CheckboxListTile(
                              value:
                                  sudahBayar
                                      ? true
                                      : selectedPeriode.contains(periode),

                              title: Text(periode),
                              controlAffinity: ListTileControlAffinity.leading,
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
                  ],
                ),
              ),
              // aksi untuk tombol simpan dan batal
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text("Batal"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (pesertaId == null || selectedPeriode.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Peserta dan periode wajib dipilih"),
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

                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: tambahPembayaranDialog,

        child: const Icon(Icons.add),
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
            return const Center(child: Text("Data pembayaran kosong"));
          }
          //jika ada data pembayaran
          final pembayaranList = snapshot.data!;

          return ListView.builder(
            itemCount: pembayaranList.length,

            itemBuilder: (context, index) {
              final pembayaran = pembayaranList[index];
              // menampilkan card pembayaran
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

                child: ListTile(
                  title: Text(pembayaran.namaPeserta ?? '-'),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text("Rp ${pembayaran.nominal}"),

                      Text("Periode : ${pembayaran.periodeBayar.join(", ")}"),

                      Text("Tanggal : ${pembayaran.tanggal}"),
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
