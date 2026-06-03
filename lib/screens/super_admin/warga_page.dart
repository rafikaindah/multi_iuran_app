import 'package:flutter/material.dart';

import '../../controllers/warga_controller.dart';
import '../../models/warga_model.dart';

//halaman untuk mengelola data warga
class WargaPage extends StatefulWidget {
  const WargaPage({super.key});

  @override
  State<WargaPage> createState() => _WargaPageState();
}

//state untuk halaman warga
class _WargaPageState extends State<WargaPage> {
  final wargaController = WargaController();

  //warna utama
  final primaryColor = const Color.fromARGB(255, 100, 161, 102);

  //fungsi untuk menampilkan dialog tambah warga
  Future<void> tambahWargaDialog() async {
    final namaController = TextEditingController();
    final alamatController = TextEditingController();
    final noHpController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
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
                    "Tambah Warga",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: namaController,
                    decoration: InputDecoration(
                      labelText: "Nama",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: alamatController,
                    decoration: InputDecoration(
                      labelText: "Alamat",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: noHpController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "No HP",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  //aksi untuk tombol simpan dan batal
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                            if (namaController.text.isEmpty ||
                                alamatController.text.isEmpty ||
                                noHpController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Semua data wajib diisi"),
                                ),
                              );
                              return;
                            }

                            await wargaController.tambahWarga(
                              nama: namaController.text,
                              alamat: alamatController.text,
                              noHp: noHpController.text,
                            );

                            Navigator.pop(context);

                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
  }

  //fungsi untuk menampilkan dialog edit warga
  Future<void> editWargaDialog(WargaModel warga) async {
    final namaController = TextEditingController(text: warga.nama);
    final alamatController = TextEditingController(text: warga.alamat);
    final noHpController = TextEditingController(text: warga.noHp);

    showDialog(
      context: context,
      builder: (_) {
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
                    "Edit Warga",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: namaController,
                    decoration: InputDecoration(
                      labelText: "Nama",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: alamatController,
                    decoration: InputDecoration(
                      labelText: "Alamat",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: noHpController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "No HP",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  //aksi untuk tombol update dan batal
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                            if (namaController.text.isEmpty ||
                                alamatController.text.isEmpty ||
                                noHpController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Semua data wajib diisi"),
                                ),
                              );
                              return;
                            }

                            await wargaController.editWarga(
                              id: warga.id,
                              nama: namaController.text,
                              alamat: alamatController.text,
                              noHp: noHpController.text,
                            );

                            Navigator.pop(context);

                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Update"),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        title: const Text("Data Warga"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: tambahWargaDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      //isi halaman berupa daftar warga yang diambil dari database
      body: FutureBuilder<List<WargaModel>>(
        future: wargaController.getWarga(),
        //menampilkan loading saat data sedang diambil
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Data warga kosong", style: TextStyle(fontSize: 16)),
            );
          }

          //menampilkan daftar warga jika data sudah tersedia
          final wargaList = snapshot.data!;

          //menampilkan data dalam bentuk list
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wargaList.length,

            itemBuilder: (context, index) {
              final warga = wargaList[index];

              //kartu untuk menampilkan data warga
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
                      // header
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              warga.nama,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // alamat
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.home_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              warga.alamat,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // no hp
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
                              warga.noHp,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        child: Text(
                          warga.status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                warga.status == 'aktif'
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // tombol aksi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            //tombol edit hanya aktif jika status warga aktif
                            onPressed:
                                warga.status == 'aktif'
                                    ? () {
                                      editWargaDialog(warga);
                                    }
                                    : null,

                            icon: Icon(
                              Icons.edit,
                              color:
                                  warga.status == 'aktif' ? primaryColor : null,
                            ),
                          ),

                          Switch(
                            value: warga.status == 'aktif',

                            activeColor: primaryColor,

                            onChanged: (value) async {
                              await wargaController.updateStatus(
                                id: warga.id,
                                status: value ? 'aktif' : 'tidak aktif',
                              );

                              setState(() {});
                            },
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
