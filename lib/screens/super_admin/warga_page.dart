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

  //fungsi untuk menampilkan dialog tambah warga
  Future<void> tambahWargaDialog() async {
    final namaController = TextEditingController();
    final alamatController = TextEditingController();
    final noHpController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Tambah Warga"),

          //isi dialog berupa form untuk input data warga
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: "Nama"),
                ),

                TextField(
                  controller: alamatController,
                  decoration: const InputDecoration(labelText: "Alamat"),
                ),

                TextField(
                  controller: noHpController,
                  decoration: const InputDecoration(labelText: "No HP"),
                ),
              ],
            ),
          ),

          //aksi untuk tombol simpan dan batal
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),

            ElevatedButton(
              onPressed: () async {
                await wargaController.tambahWarga(
                  nama: namaController.text,
                  alamat: alamatController.text,
                  noHp: noHpController.text,
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
  }

  //fungsi untuk menampilkan dialog edit warga
  Future<void> editWargaDialog(WargaModel warga) async {
    final namaController = TextEditingController(text: warga.nama);
    final alamatController = TextEditingController(text: warga.alamat);
    final noHpController = TextEditingController(text: warga.noHp);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Edit Warga"),

          //isi dialog berupa form untuk mengedit data warga yang sudah ada
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: "Nama"),
                ),

                TextField(
                  controller: alamatController,
                  decoration: const InputDecoration(labelText: "Alamat"),
                ),

                TextField(
                  controller: noHpController,
                  decoration: const InputDecoration(labelText: "No HP"),
                ),
              ],
            ),
          ),

          //aksi untuk tombol update dan batal
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),

            ElevatedButton(
              onPressed: () async {
                await wargaController.editWarga(
                  id: warga.id,
                  nama: namaController.text,
                  alamat: alamatController.text,
                  noHp: noHpController.text,
                );

                Navigator.pop(context);

                setState(() {});
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  //mengatur tampilan halaman warga
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Warga")),

      floatingActionButton: FloatingActionButton(
        onPressed: tambahWargaDialog,
        child: const Icon(Icons.add),
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
            return const Center(child: Text("Data warga kosong"));
          }

          //menampilkan daftar warga jika data sudah tersedia
          final wargaList = snapshot.data!;

          //menampilkan data dalam bentuk list
          return ListView.builder(
            itemCount: wargaList.length,

            itemBuilder: (context, index) {
              final warga = wargaList[index];

              //kartu untuk menampilkan data warga
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

                child: ListTile(
                  title: Text(warga.nama),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(warga.alamat),

                      Text(warga.noHp),

                      Text("Status: ${warga.status}"),
                    ],
                  ),

                  //aksi untuk tombol edit dan switch status warga
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        //tombol edit hanya aktif jika status warga aktif
                        onPressed:
                            warga.status == 'aktif'
                                ? () {
                                  editWargaDialog(warga);
                                }
                                : null,
                        icon: const Icon(Icons.edit),
                      ),

                      Switch(
                        value: warga.status == 'aktif',

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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
