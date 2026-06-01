import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../controllers/pengeluaran_controller.dart';
import '../../../../controllers/storage_controller.dart';
import '../../../../models/pengeluaran_model.dart';

//halaman pengeluaran admin iuran
class PengeluaranPage extends StatefulWidget {
  final Map<String, dynamic> iuran;

  const PengeluaranPage({super.key, required this.iuran});

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

// state untuk halaman pengeluaran
class _PengeluaranPageState extends State<PengeluaranPage> {
  final pengeluaranController = PengeluaranController();

  final storageController = StorageController();

  final picker = ImagePicker();

  File? selectedImage;

  // fungsi pilih gambar
  Future<void> pickImage(StateSetter setStateDialog) async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setStateDialog(() {
        selectedImage = File(image.path);
      });
    }
  }

  //dialog tambah pengeluaran
  Future<void> tambahPengeluaranDialog() async {
    final nominalController = TextEditingController();

    final tanggalController = TextEditingController(
      text: DateTime.now().toString().split(' ')[0],
    );

    final keteranganController = TextEditingController();

    // reset gambar saat dialog dibuka
    selectedImage = null;

    showDialog(
      context: context,

      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Tambah Pengeluaran"),
              // isi dialog untuk input nominal, tanggal, dan keterangan
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    TextField(
                      controller: nominalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Nominal"),
                    ),

                    TextField(
                      controller: tanggalController,
                      decoration: const InputDecoration(labelText: "Tanggal"),
                    ),

                    TextField(
                      controller: keteranganController,
                      decoration: const InputDecoration(
                        labelText: "Keterangan",
                      ),
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton(
                      onPressed: () {
                        pickImage(setStateDialog);
                      },

                      child: const Text("Pilih Bukti Foto"),
                    ),

                    // preview gambar
                    if (selectedImage != null)
                      Container(
                        margin: const EdgeInsets.only(top: 10),

                        height: 200,

                        width: double.infinity,

                        child: Image.file(selectedImage!, fit: BoxFit.cover),
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
                    if (nominalController.text.isEmpty ||
                        keteranganController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Semua field wajib diisi"),
                        ),
                      );

                      return;
                    }

                    String? imageUrl;

                    // upload gambar
                    if (selectedImage != null) {
                      imageUrl = await storageController.uploadFoto(
                        selectedImage!,
                      );
                    }

                    await pengeluaranController.tambahPengeluaran(
                      iuranId: widget.iuran['id'],
                      nominal: int.parse(
                        nominalController.text.replaceAll('.', ''),
                      ),
                      tanggal: tanggalController.text,
                      keterangan: keteranganController.text,
                      buktiFoto: imageUrl,
                    );

                    Navigator.pop(context);

                    setState(() {
                      selectedImage = null;
                    });
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
        onPressed:
            widget.iuran['status'] == 'aktif'
                ? tambahPengeluaranDialog
                : null, // tombol tidak aktif jika iuran tidak aktif
        child: const Icon(Icons.add),
      ),
      // body untuk menampilkan daftar pengeluaran
      body: FutureBuilder<List<PengeluaranModel>>(
        future: pengeluaranController.getPengeluaran(widget.iuran['id']),

        builder: (context, snapshot) {
          //loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          //jika kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Data pengeluaran kosong"));
          }
          //jika ada data pengeluaran
          final pengeluaranList = snapshot.data!;

          return ListView.builder(
            itemCount: pengeluaranList.length,

            itemBuilder: (context, index) {
              final pengeluaran = pengeluaranList[index];
              // menampilkan card pengeluaran
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

                child: ListTile(
                  title: Text("Rp ${pengeluaran.nominal}"),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(pengeluaran.keterangan),

                      Text("Tanggal : ${pengeluaran.tanggal}"),

                      // gambar bukti
                      if (pengeluaran.buktiFoto != null)
                        Container(
                          margin: const EdgeInsets.only(top: 10),

                          height: 200,

                          width: double.infinity,

                          child: Image.network(
                            pengeluaran.buktiFoto!,
                            fit: BoxFit.cover,
                          ),
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
