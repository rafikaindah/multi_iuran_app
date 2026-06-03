import 'package:flutter/material.dart';
import '../../controllers/admin_controller.dart';

//halaman admin
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final adminController = AdminController();

  //warna utama
  final primaryColor = const Color.fromARGB(255, 100, 161, 102);

  //dialog tambah admin
  Future<void> tambahAdminDialog() async {
    final namaController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final iuranList = await adminController.getIuranAktif();

    List<String> selectedIuranIds = [];
    bool isPasswordHidden = true;

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
                        "Tambah Admin",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      //nama
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

                      //email
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      //password
                      TextField(
                        controller: passwordController,
                        obscureText: isPasswordHidden,
                        decoration: InputDecoration(
                          labelText: "Password",

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),

                          suffixIcon: IconButton(
                            onPressed: () {
                              setModalState(() {
                                isPasswordHidden = !isPasswordHidden;
                              });
                            },

                            icon: Icon(
                              isPasswordHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Pilih Iuran",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(height: 10),

                      //checkbox iuran aktif
                      ...iuranList.map((iuran) {
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: primaryColor,
                          value: selectedIuranIds.contains(iuran['id']),
                          title: Text(iuran['nama_iuran']),

                          onChanged: (value) {
                            setModalState(() {
                              if (value == true) {
                                selectedIuranIds.add(iuran['id']);
                              } else {
                                selectedIuranIds.remove(iuran['id']);
                              }
                            });
                          },
                        );
                      }),

                      const SizedBox(height: 20),

                      //tombol
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
                                //validasi
                                if (namaController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Nama wajib diisi"),
                                    ),
                                  );
                                  return;
                                }

                                if (emailController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Email wajib diisi"),
                                    ),
                                  );
                                  return;
                                }

                                if (passwordController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Password wajib diisi"),
                                    ),
                                  );
                                  return;
                                }

                                if (selectedIuranIds.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Pilih minimal 1 iuran"),
                                    ),
                                  );
                                  return;
                                }

                                //simpan admin
                                await adminController.tambahAdmin(
                                  nama: namaController.text,
                                  email: emailController.text,
                                  password: passwordController.text,
                                  iuranIds: selectedIuranIds,
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

  //dialog edit admin
  Future<void> editAdminDialog(Map<String, dynamic> item) async {
    final admin = item['admin_iuran'];
    final namaController = TextEditingController(text: admin['nama']);
    final emailController = TextEditingController(text: admin['email']);
    final adminId = admin['id'];
    final iuranList = await adminController.getIuranAktif();

    //ambil relasi admin
    final relasiData = await adminController.supabase
        .from('admin_iuran_relasi')
        .select()
        .eq('admin_id', adminId)
        .eq('status', 'aktif');

    List<String> selectedIuranIds =
        relasiData.map<String>((e) {
          return e['iuran_id'] as String;
        }).toList();

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
                        "Edit Admin",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Pilih Iuran",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),

                      //checkbox iuran aktif
                      ...iuranList.map((iuran) {
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: primaryColor,
                          value: selectedIuranIds.contains(iuran['id']),

                          title: Text(iuran['nama_iuran']),
                          onChanged: (value) {
                            setModalState(() {
                              if (value == true) {
                                selectedIuranIds.add(iuran['id']);
                              } else {
                                selectedIuranIds.remove(iuran['id']);
                              }
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 20),

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
                                if (namaController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Nama wajib diisi"),
                                    ),
                                  );
                                  return;
                                }

                                if (emailController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Email wajib diisi"),
                                    ),
                                  );
                                  return;
                                }

                                if (selectedIuranIds.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Pilih minimal 1 iuran"),
                                    ),
                                  );
                                  return;
                                }

                                await adminController.editAdminLengkap(
                                  adminId: adminId,
                                  nama: namaController.text,
                                  email: emailController.text,
                                  iuranIds: selectedIuranIds,
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
        title: const Text("Data Admin"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: tambahAdminDialog,

        child: const Icon(Icons.add, color: Colors.white),
      ),

      //tampilkan list admin
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: adminController.getAdmin(),

        builder: (context, snapshot) {
          //loading saat ambil data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          //jika data kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Data admin kosong", style: TextStyle(fontSize: 16)),
            );
          }
          //menampilkan data admin jika ada
          final adminList = snapshot.data!;
          //menampilkan data admin dalam bentuk list
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: adminList.length,

            itemBuilder: (context, index) {
              final item = adminList[index];
              final relasiId = item['id'];
              final status = item['status'];
              final admin = item['admin_iuran'];
              final iuran = item['iuran'];

              //kartu untuk menampilkan data admin
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
                      //nama admin
                      Text(
                        admin['nama'],

                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      //email
                      Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              admin['email'],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      //iuran
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
                              iuran['nama_iuran'],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      //status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        child: Text(
                          status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,

                            color:
                                status == 'aktif' ? Colors.green : Colors.red,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      //aksi edit dan switch status admin
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,

                        children: [
                          IconButton(
                            onPressed:
                                status == 'aktif'
                                    ? () {
                                      editAdminDialog(item);
                                    }
                                    : null,
                            icon: Icon(
                              Icons.edit,
                              color: status == 'aktif' ? primaryColor : null,
                            ),
                          ),

                          Switch(
                            value: status == 'aktif',
                            activeColor: primaryColor,

                            onChanged: (value) async {
                              await adminController.updateStatusRelasi(
                                relasiId: relasiId,

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
