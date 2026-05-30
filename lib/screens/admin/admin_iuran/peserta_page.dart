import 'package:flutter/material.dart';
import '../../../controllers/peserta_controller.dart';
import '../../../models/peserta_model.dart';

//halaman untuk mengelola peserta iuran
class PesertaPage extends StatefulWidget {
  final Map<String, dynamic> iuran;

  const PesertaPage({super.key, required this.iuran});

  @override
  State<PesertaPage> createState() => _PesertaPageState();
}

// state untuk halaman peserta
class _PesertaPageState extends State<PesertaPage> {
  final pesertaController = PesertaController();

  // fungsi untuk menampilkan dialog tambah peserta
  Future<void> tambahPesertaDialog() async {
    String? selectedWargaId;

    final wargaList = await pesertaController.getWargaAktif();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text("Tambah Peserta"),
              // isi dialog untuk pilih warga
              content: DropdownButtonFormField<String>(
                value: selectedWargaId,
                items:
                    wargaList.map<DropdownMenuItem<String>>((warga) {
                      return DropdownMenuItem<String>(
                        value: warga['id'].toString(),
                        child: Text(warga['nama'].toString()),
                      );
                    }).toList(),
                onChanged: (value) {
                  setModalState(() {
                    selectedWargaId = value;
                  });
                },
                decoration: const InputDecoration(labelText: "Pilih Warga"),
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
                    // validasi jika warga belum dipilih
                    if (selectedWargaId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Warga wajib dipilih")),
                      );
                      return;
                    }

                    await pesertaController.tambahPeserta(
                      wargaId: selectedWargaId!,
                      iuranId: widget.iuran['id'],
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

  // detail peserta
  Future<void> detailPesertaDialog(PesertaModel peserta) async {
    final riwayatPembayaran = await pesertaController.getRiwayatPembayaran(
      peserta.id,
    );
    final statusPembayaran = await pesertaController.getStatusPembayaran(
      pesertaId: peserta.id,
      iuran: widget.iuran,
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Detail Peserta"),

          content: SizedBox(
            width: double.maxFinite,

            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nama : ${peserta.namaWarga}"),
                  const SizedBox(height: 8),

                  Text("Alamat : ${peserta.alamat}"),
                  const SizedBox(height: 8),

                  Text("No HP : ${peserta.noHp}"),
                  const SizedBox(height: 8),

                  Text("Iuran : ${peserta.namaIuran}"),
                  const SizedBox(height: 8),

                  Text("Status : ${peserta.status}"),
                  const SizedBox(height: 8),

                  Text("Status Pembayaran : ${statusPembayaran['status']}"),
                  const SizedBox(height: 8),

                  Text(
                    "Jumlah Tunggakan : ${statusPembayaran['jumlah_tunggakan']}",
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Riwayat Pembayaran",

                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  if (riwayatPembayaran.isEmpty)
                    const Text("Belum ada pembayaran"),

                  ...riwayatPembayaran.map((item) {
                    final periode = List<String>.from(
                      item['periode_bayar'] ?? [],
                    );

                    return Card(
                      child: ListTile(
                        title: Text("Rp ${item['nominal']}"),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text("Periode : ${periode.join(", ")}"),

                            Text("Tanggal : ${item['tanggal']}"),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Peserta ${widget.iuran['nama_iuran']}")),

      floatingActionButton: FloatingActionButton(
        onPressed: tambahPesertaDialog,
        child: const Icon(Icons.add),
      ),

      body: FutureBuilder<List<PesertaModel>>(
        future: pesertaController.getPeserta(widget.iuran['id']),

        builder: (context, snapshot) {
          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // jika kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Data peserta kosong"));
          }

          // list peserta
          final pesertaList = snapshot.data!;

          return ListView.builder(
            itemCount: pesertaList.length,

            itemBuilder: (context, index) {
              final peserta = pesertaList[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

                child: ListTile(
                  title: Text(peserta.namaWarga),

                  subtitle: Text("Status: ${peserta.status}"),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // detail
                      IconButton(
                        onPressed:
                            peserta.statusWarga == 'aktif'
                                ? () {
                                  detailPesertaDialog(peserta);
                                }
                                : null,
                        icon: const Icon(Icons.info),
                      ),

                      // switch status
                      Switch(
                        value: peserta.status == 'aktif',

                        onChanged:
                            peserta.statusWarga == 'aktif'
                                ? (value) async {
                                  await pesertaController.updateStatus(
                                    id: peserta.id,
                                    status: value ? 'aktif' : 'tidak aktif',
                                  );

                                  setState(() {});
                                }
                                : null,
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
