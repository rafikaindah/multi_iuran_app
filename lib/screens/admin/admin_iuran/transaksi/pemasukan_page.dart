import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../controllers/pemasukan_controller.dart';
import '../../../../controllers/storage_controller.dart';
import '../../../../models/pemasukan_model.dart';

//halaman pemasukan admin iuran
class PemasukanPage extends StatefulWidget {
  final Map<String, dynamic> iuran;

  const PemasukanPage({super.key, required this.iuran});

  @override
  State<PemasukanPage> createState() => _PemasukanPageState();
}

// state untuk halaman pemasukan
class _PemasukanPageState extends State<PemasukanPage> {
  final pemasukanController = PemasukanController();

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

  //dialog tambah pemasukan
  Future<void> tambahPemasukanDialog() async {
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
              title: const Text("Tambah Pemasukan"),
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
                          content: Text("Semua kolom wajib diisi"),
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

                    await pemasukanController.tambahPemasukan(
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
        onPressed: tambahPemasukanDialog,

        child: const Icon(Icons.add),
      ),
      // body untuk menampilkan daftar pemasukan
      body: FutureBuilder<List<PemasukanModel>>(
        future: pemasukanController.getPemasukan(widget.iuran['id']),

        builder: (context, snapshot) {
          //loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          //jika kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Data pemasukan kosong"));
          }
          //jika ada data pemasukan
          final pemasukanList = snapshot.data!;

          return ListView.builder(
            itemCount: pemasukanList.length,

            itemBuilder: (context, index) {
              final pemasukan = pemasukanList[index];
              // menampilkan card pemasukan
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

                child: ListTile(
                  title: Text("Rp ${pemasukan.nominal}"),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(pemasukan.keterangan),

                      Text("Tanggal : ${pemasukan.tanggal}"),

                      // gambar bukti
                      if (pemasukan.buktiFoto != null)
                        Container(
                          margin: const EdgeInsets.only(top: 10),

                          height: 200,

                          width: double.infinity,

                          child: Image.network(
                            pemasukan.buktiFoto!,
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
