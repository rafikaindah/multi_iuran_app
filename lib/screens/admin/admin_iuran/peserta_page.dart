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
  final primaryColor = const Color.fromARGB(255, 100, 161, 102);

  // fungsi untuk menampilkan dialog tambah peserta
  Future<void> tambahPesertaDialog() async {
    String? selectedWargaId;

    final wargaList = await pesertaController.getWargaAktif();
    final pesertaList = await pesertaController.getPeserta(widget.iuran['id']);
    // daftar id warga yang sudah terdaftar
    final pesertaTerdaftarIds = pesertaList.map((e) => e.wargaId).toSet();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Tambah Peserta",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        value: selectedWargaId,

                        decoration: InputDecoration(
                          labelText: "Pilih Warga",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        items:
                            wargaList.map<DropdownMenuItem<String>>((warga) {
                              final sudahTerdaftar = pesertaTerdaftarIds
                                  .contains(warga['id']);

                              return DropdownMenuItem<String>(
                                value: warga['id'].toString(),
                                child: Text(
                                  warga['nama'].toString(),
                                  style: TextStyle(
                                    fontWeight:
                                        sudahTerdaftar
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color:
                                        sudahTerdaftar
                                            ? Colors.red
                                            : Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          // jika sudah terdaftar
                          if (pesertaTerdaftarIds.contains(value)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Warga sudah terdaftar pada iuran ini",
                                ),
                              ),
                            );

                            return;
                          }

                          setModalState(() {
                            selectedWargaId = value;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "* Nama merah tebal berarti sudah terdaftar",
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ),

                      const SizedBox(height: 25),

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
                                // validasi jika warga belum dipilih
                                if (selectedWargaId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Warga wajib dipilih"),
                                    ),
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

  // detail peserta
  Future<void> detailPesertaDialog(PesertaModel peserta) async {
    final riwayatPembayaran = await pesertaController.getRiwayatPembayaran(
      peserta.id,
    );
    final statusPembayaran = await pesertaController.getStatusPembayaran(
      pesertaId: peserta.id,
      iuran: widget.iuran,
    );

    Widget detailItem(String title, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            SizedBox(
              width: 140,

              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            const Text(": "),

            Expanded(child: Text(value, softWrap: true)),
          ],
        ),
      );
    }

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,

              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // judul
                    const Center(
                      child: Text(
                        "Detail Peserta",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // data peserta
                    detailItem("Nama", peserta.namaWarga),
                    detailItem("Alamat", peserta.alamat),

                    detailItem("No HP", peserta.noHp),
                    detailItem("Iuran", peserta.namaIuran),
                    detailItem("Status Peserta", peserta.status),
                    detailItem("Status Pembayaran", statusPembayaran['status']),
                    detailItem(
                      "Jumlah Tunggakan",
                      "${statusPembayaran['jumlah_tunggakan']}",
                    ),

                    const SizedBox(height: 20),

                    const Divider(),

                    const SizedBox(height: 10),

                    const Text(
                      "Riwayat Pembayaran",

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // jika kosong
                    if (riwayatPembayaran.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: const Text(
                          "Belum ada pembayaran",
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // list riwayat pembayaran
                    ...riwayatPembayaran.map((item) {
                      final periode = List<String>.from(
                        item['periode_bayar'] ?? [],
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Rp ${item['nominal']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Periode : "),
                                Expanded(
                                  child: Text(
                                    periode.join(", "),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Tanggal : "),
                                Expanded(
                                  child: Text(
                                    item['tanggal'].toString(),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 10),

                    // tombol tutup
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        child: const Text("Tutup"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        title: Text("Peserta ${widget.iuran['nama_iuran']}"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,

        onPressed:
            widget.iuran['status'] == 'aktif' ? tambahPesertaDialog : null,
        child: const Icon(Icons.add, color: Colors.white),
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: pesertaList.length,

            itemBuilder: (context, index) {
              final peserta = pesertaList[index];

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
                      // detail
                      Text(
                        peserta.namaWarga,

                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // alamat
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              peserta.alamat,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // nomor hp
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              peserta.noHp,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // status peserta
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        child: Text(
                          peserta.status,

                          style: TextStyle(
                            fontWeight: FontWeight.bold,

                            color:
                                peserta.status == 'aktif'
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // tombol aksi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,

                        children: [
                          IconButton(
                            onPressed: () {
                              detailPesertaDialog(peserta);
                            },

                            icon: Icon(Icons.info_outline, color: primaryColor),
                          ),
                          // switch status
                          Switch(
                            value: peserta.status == 'aktif',

                            activeColor: primaryColor,

                            onChanged:
                                peserta.statusWarga == 'aktif' &&
                                        widget.iuran['status'] == 'aktif'
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
