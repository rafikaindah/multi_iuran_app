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

  final Color primaryColor = const Color.fromARGB(255, 100, 161, 102);

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
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Tambah Pemasukan",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: nominalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Nominal",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: tanggalController,
                        decoration: InputDecoration(
                          labelText: "Tanggal",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: keteranganController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: "Keterangan",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            pickImage(setStateDialog);
                          },
                          icon: const Icon(Icons.image),
                          label: const Text("Pilih Bukti Foto"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      // preview gambar
                      if (selectedImage != null) ...[
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            selectedImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

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
                ? tambahPemasukanDialog
                : null, // tombol tidak aktif jika iuran tidak aktif
        child: const Icon(Icons.add, color: Colors.white),
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
            return const Center(
              child: Text(
                "Data pemasukan kosong",
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          //jika ada data pemasukan
          final pemasukanList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: pemasukanList.length,

            itemBuilder: (context, index) {
              final pemasukan = pemasukanList[index];
              // menampilkan card pemasukan
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
                            child: Text(
                              "Rp ${pemasukan.nominal}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Keterangan : ${pemasukan.keterangan}",
                        style: const TextStyle(fontSize: 14),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Text(
                            "Tanggal : ${pemasukan.tanggal}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),

                      // gambar bukti
                      if (pemasukan.buktiFoto != null) ...[
                        const SizedBox(height: 14),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),

                          child: Image.network(
                            pemasukan.buktiFoto!,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
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
