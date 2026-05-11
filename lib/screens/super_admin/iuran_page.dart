import 'package:flutter/material.dart';

import '../../controllers/iuran_controller.dart';
import '../../models/iuran_model.dart';

//halaman untuk mengelola data iuran
class IuranPage extends StatefulWidget {
  const IuranPage({super.key});

  @override
  State<IuranPage> createState() => _IuranPageState();
}

//state untuk halaman iuran
class _IuranPageState extends State<IuranPage> {
  final iuranController = IuranController();

  //fungsi untuk menampilkan dialog tambah iuran
  Future<void> tambahIuranDialog() async {
    final namaController = TextEditingController();
    final nominalController = TextEditingController();

    //periode iuran bisa null
    String? periode;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text("Tambah Iuran"),

              // isi dialog berupa form untuk input data iuran
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: "Nama Iuran *",
                      ),
                    ),

                    TextField(
                      controller: nominalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Nominal (Opsional)",
                      ),
                    ),

                    DropdownButtonFormField<String>(
                      value: periode,

                      items: const [
                        DropdownMenuItem(
                          value: 'Mingguan',
                          child: Text('Mingguan'),
                        ),

                        DropdownMenuItem(
                          value: 'Bulanan',
                          child: Text('Bulanan'),
                        ),
                      ],

                      onChanged: (value) {
                        setModalState(() {
                          periode = value;
                        });
                      },

                      decoration: const InputDecoration(
                        labelText: "Periode (Opsional)",
                      ),
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
                    // validasi input nama iuran wajib diisi
                    if (namaController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Nama iuran wajib diisi")),
                      );
                      return;
                    }
                    // nominal bisa null
                    await iuranController.tambahIuran(
                      namaIuran: namaController.text,

                      nominal:
                          nominalController.text.isEmpty
                              ? null
                              : int.parse(nominalController.text),
                      // periode bisa null
                      periode: periode,
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

  //fungsi untuk menampilkan dialog edit iuran
  Future<void> editIuranDialog(IuranModel iuran) async {
    final namaController = TextEditingController(text: iuran.namaIuran);

    // nominal bisa null, jika null maka isi controller dengan string kosong
    final nominalController = TextEditingController(
      text: iuran.nominal?.toString() ?? '',
    );

    // periode bisa null, jika null maka isi controller dengan string kosong
    String? periode = iuran.periode;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text("Edit Iuran"),

              // isi dialog berupa form untuk input data iuran
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: "Nama Iuran *",
                      ),
                    ),

                    TextField(
                      controller: nominalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Nominal (Opsional)",
                      ),
                    ),

                    DropdownButtonFormField<String>(
                      value: periode,

                      items: const [
                        DropdownMenuItem(
                          value: 'Mingguan',
                          child: Text('Mingguan'),
                        ),

                        DropdownMenuItem(
                          value: 'Bulanan',
                          child: Text('Bulanan'),
                        ),
                      ],

                      onChanged: (value) {
                        setModalState(() {
                          periode = value;
                        });
                      },

                      decoration: const InputDecoration(
                        labelText: "Periode (Opsional)",
                      ),
                    ),
                  ],
                ),
              ),

              // aksi untuk tombol update dan batal
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Batal"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    // validasi input nama iuran wajib diisi
                    if (namaController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Nama iuran wajib diisi")),
                      );
                      return;
                    }
                    // nominal bisa null
                    await iuranController.editIuran(
                      id: iuran.id,

                      namaIuran: namaController.text,

                      nominal:
                          nominalController.text.isEmpty
                              ? null
                              : int.parse(nominalController.text),
                      // periode bisa null
                      periode: periode,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Iuran")),

      floatingActionButton: FloatingActionButton(
        onPressed: tambahIuranDialog,
        child: const Icon(Icons.add),
      ),

      //isian halaman berupa list data iuran yang diambil dari database
      body: FutureBuilder<List<IuranModel>>(
        future: iuranController.getIuran(),

        builder: (context, snapshot) {
          // menampilkan loading saat data sedang diambil
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // jika data sudah diambil tetapi kosong, tampilkan pesan data kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Data iuran kosong"));
          }
          // menampilkan daftar iuran jika data sudah tersedia
          final iuranList = snapshot.data!;
          // menampilkan data dalam bentuk list
          return ListView.builder(
            itemCount: iuranList.length,

            itemBuilder: (context, index) {
              final iuran = iuranList[index];

              //kartu untuk menampilkan data iuran
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

                child: ListTile(
                  title: Text(iuran.namaIuran),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        iuran.nominal != null
                            ? "Rp ${iuran.nominal}"
                            : "Nominal fleksibel",
                      ),

                      Text(iuran.periode ?? "Tanpa periode"),

                      Text("Status: ${iuran.status}"),
                    ],
                  ),

                  //aksi untuk edit dan switch status iuran
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        // tombol edit hanya aktif jika status iuran aktif
                        onPressed:
                            iuran.status == 'aktif'
                                ? () {
                                  editIuranDialog(iuran);
                                }
                                : null,

                        icon: const Icon(Icons.edit),
                      ),

                      Switch(
                        value: iuran.status == 'aktif',

                        onChanged: (value) async {
                          await iuranController.updateStatus(
                            id: iuran.id,

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
