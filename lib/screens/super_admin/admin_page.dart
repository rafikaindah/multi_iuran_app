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

  //dialog tambah admin
  Future<void> tambahAdminDialog() async {
    final namaController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final iuranList = await adminController.getIuranAktif();

    List<String> selectedIuranIds = [];

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text("Tambah Admin"),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(labelText: "Nama *"),
                    ),

                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email *"),
                    ),

                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password *",
                      ),
                    ),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Pilih Iuran *"),
                    ),

                    //checkbox iuran aktif
                    ...iuranList.map((iuran) {
                      return CheckboxListTile(
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
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text("Batal"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    //validasi
                    if (namaController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Nama wajib diisi")),
                      );
                      return;
                    }

                    if (emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Email wajib diisi")),
                      );
                      return;
                    }

                    if (passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Password wajib diisi")),
                      );
                      return;
                    }

                    if (selectedIuranIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Pilih minimal 1 iuran")),
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

                  child: const Text("Simpan"),
                ),
              ],
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
        .eq('admin_id', adminId);

    List<String> selectedIuranIds =
        relasiData.map<String>((e) {
          return e['iuran_id'] as String;
        }).toList();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text("Edit Admin"),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(labelText: "Nama *"),
                    ),

                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email *"),
                    ),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Pilih Iuran *"),
                    ),

                    //checkbox iuran aktif
                    ...iuranList.map((iuran) {
                      return CheckboxListTile(
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
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text("Batal"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (namaController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Nama wajib diisi")),
                      );
                      return;
                    }

                    if (emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Email wajib diisi")),
                      );
                      return;
                    }

                    if (selectedIuranIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Pilih minimal 1 iuran")),
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
      appBar: AppBar(title: const Text("Data Admin")),

      floatingActionButton: FloatingActionButton(
        onPressed: tambahAdminDialog,

        child: const Icon(Icons.add),
      ),

      //tampilkan list admin
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: adminController.getAdmin(),

        builder: (context, snapshot) {
          //loading saat ambil data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // jika data kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Data admin kosong"));
          }
          //menampilkan data admin jika ada
          final adminList = snapshot.data!;
          //menampilkan data admin dalam bentuk list
          return ListView.builder(
            itemCount: adminList.length,

            itemBuilder: (context, index) {
              final item = adminList[index];
              final relasiId = item['id'];
              final status = item['status'];
              final admin = item['admin_iuran'];
              final iuran = item['iuran'];

              //kartu untuk menampilkan data admin
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

                child: ListTile(
                  title: Text(admin['nama']),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(admin['email']),
                      Text("Iuran: ${iuran['nama_iuran']}"),
                      Text("Status: $status"),
                    ],
                  ),

                  //aksi edit dan switch status admin
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          editAdminDialog(item);
                        },

                        icon: const Icon(Icons.edit),
                      ),

                      Switch(
                        value: status == 'aktif',

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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
