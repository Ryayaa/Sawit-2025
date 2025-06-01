import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  List<Map<String, dynamic>> _userList = [];

  @override
  void initState() {
    super.initState();
    _fetchUsersFromFirebase();
  }

  void _fetchUsersFromFirebase() async {
    final databaseReference = FirebaseDatabase.instance.ref().child('User');
    final snapshot = await databaseReference.get();

    if (snapshot.exists) {
      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      setState(() {
        _userList = data.entries.map((entry) {
          final Map<dynamic, dynamic> userData = entry.value;
          return {
            'id': entry.key,
            'name': userData['name'] ?? '',
            'email': userData['email'] ?? '',
            'alamat': userData['alamat'] ?? '',
            'nomor_telepon': userData['nomor_telepon'] ?? '',
            'role': userData['role']?.toString() ?? '',
          };
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 39, 39, 39),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 39, 39),
        title: const Text('Data User'),
        centerTitle: true,
      ),
      body: _userList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _userList.length,
              itemBuilder: (context, index) {
                final user = _userList[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    leading: const Icon(Icons.person),
                    title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(user['email']),
                    children: [
                      ListTile(
                        title: Text("Nomor Telepon: ${user['nomor_telepon']}"),
                        subtitle: Text("Alamat: ${user['alamat']}"),
                        trailing: Text("Role: ${user['role']}"),
                      ),
                      ButtonBar(
                        children: [
                          TextButton.icon(
                        onPressed: () {
                          _showEditDialog(user); // panggil dialog edit
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

void _showEditDialog(Map<String, dynamic> userData) {
  TextEditingController nameController = TextEditingController(text: userData['name']);
  TextEditingController emailController = TextEditingController(text: userData['email']);
  TextEditingController phoneController = TextEditingController(text: userData['nomor_telepon']);
  TextEditingController addressController = TextEditingController(text: userData['alamat']);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit Data User'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                readOnly: true,  // <-- ini yang ditambahkan agar readonly
              ),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Nomor Telepon')),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Alamat')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              String userId = userData['id'];
              DatabaseReference userRef = FirebaseDatabase.instance.ref().child('User').child(userId);

              await userRef.update({
                'name': nameController.text.trim(),
                // 'email' tidak diupdate karena readonly
                'nomor_telepon': phoneController.text.trim(),
                'alamat': addressController.text.trim(),
              });

              Navigator.pop(context);
              _fetchUsersFromFirebase();
            },
            child: const Text('Simpan'),
          ),
        ],
      );
    },
  );
}
}