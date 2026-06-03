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

  //warna utama
  final primaryColor = const Color.fromARGB(255, 100, 161, 102);

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
                        "Tambah Iuran",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: namaController,
                        decoration: InputDecoration(
                          labelText: "Nama Iuran",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      TextField(
                        controller: nominalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Nominal (Opsional)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        value: periode,
                        decoration: InputDecoration(
                          labelText: "Periode",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

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
                                // validasi input nama iuran wajib diisi
                                if (namaController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Nama iuran wajib diisi"),
                                    ),
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
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: SingleChildScrollView(
                  // isi dialog berupa form untuk input data iuran
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Edit Iuran",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: namaController,
                        decoration: InputDecoration(
                          labelText: "Nama Iuran",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      TextField(
                        controller: nominalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Nominal (Opsional)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        value: periode,

                        decoration: InputDecoration(
                          labelText: "Periode",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

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
                      ),
                      const SizedBox(height: 25),

                      // aksi untuk tombol update dan batal
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
                                // validasi input nama iuran wajib diisi
                                if (namaController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Nama iuran wajib diisi"),
                                    ),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        title: const Text("Data Iuran"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: tambahIuranDialog,
        child: const Icon(Icons.add, color: Colors.white),
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
            return const Center(
              child: Text("Data iuran kosong", style: TextStyle(fontSize: 16)),
            );
          }
          // menampilkan daftar iuran jika data sudah tersedia
          final iuranList = snapshot.data!;
          // menampilkan data dalam bentuk list
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: iuranList.length,

            itemBuilder: (context, index) {
              final iuran = iuranList[index];

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
                      // nama iuran
                      Text(
                        iuran.namaIuran,

                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // nominal
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.payments_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              iuran.nominal != null
                                  ? "Rp ${iuran.nominal}"
                                  : "Nominal fleksibel",

                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // periode
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              iuran.periode ?? "Tanpa periode",

                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        child: Text(
                          iuran.status,

                          style: TextStyle(
                            fontWeight: FontWeight.bold,

                            color:
                                iuran.status == 'aktif'
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      //aksi untuk edit dan switch status iuran
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            // tombol edit hanya aktif jika status iuran aktif
                            onPressed:
                                iuran.status == 'aktif'
                                    ? () {
                                      editIuranDialog(iuran);
                                    }
                                    : null,

                            icon: Icon(
                              Icons.edit,
                              color:
                                  iuran.status == 'aktif' ? primaryColor : null,
                            ),
                          ),

                          Switch(
                            value: iuran.status == 'aktif',

                            activeColor: primaryColor,

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
