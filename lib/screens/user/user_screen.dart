import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin/screens/main/components/side_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> with TickerProviderStateMixin {
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
  backgroundColor: const Color(0xFF1E1E1E),
  appBar: AppBar(
    backgroundColor: const Color(0xFF121212),
    title: const Text('Data User', style: TextStyle(fontWeight: FontWeight.bold)),
    centerTitle: true,
    elevation: 4,
    shadowColor: Colors.black45,
    // Tambahkan tombol menu (ikon drawer) secara eksplisit:
    leading: Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu, color: Colors.amber),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    ),
  ),
  drawer: const SideMenu(),
      body: _userList.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            )
          : ListView.builder(
              itemCount: _userList.length,
              itemBuilder: (context, index) {
                final user = _userList[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: Card(
                    color: const Color(0xFF2A2A2A),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: const Icon(Icons.person, color: Colors.amber),
                        iconColor: Colors.white,
                        collapsedIconColor: Colors.amberAccent,
                        textColor: Colors.white,
                        collapsedTextColor: Colors.white,
                        title: Text(
                          user['name'],
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        subtitle: Text(user['email'], style: const TextStyle(color: Colors.grey)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("📞 ${user['nomor_telepon']}", style: const TextStyle(color: Colors.white)),
                                const SizedBox(height: 4),
                                Text("🏠 ${user['alamat']}", style: const TextStyle(color: Colors.white70)),
                                const SizedBox(height: 4),
                                Chip(
                                  label: Text("Role: ${user['role']}",
                                      style: const TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.deepPurple,
                                ),
                              ],
                            ),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  _showEditDialog(user);
                                },
                                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                label: const Text('Edit', style: TextStyle(color: Colors.blueAccent)),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  overlayColor: Colors.blue.withOpacity(0.1),
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
            ),
    );
  }

  void _showEditDialog(Map<String, dynamic> userData) {
    TextEditingController nameController = TextEditingController(text: userData['name']);
    TextEditingController emailController = TextEditingController(text: userData['email']);
    TextEditingController phoneController = TextEditingController(text: userData['nomor_telepon']);
    TextEditingController addressController = TextEditingController(text: userData['alamat']);
    // TextEditingController passwordController = TextEditingController(); // Tambahan
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: AnimationController(
              vsync: this,
              duration: const Duration(milliseconds: 300),
            )..forward(),
            curve: Curves.easeOutBack,
          ),
          child: AlertDialog(
            backgroundColor: const Color(0xFF2C2C2C),
            title: const Text('Edit Data User', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField('Name', nameController),
                  _buildTextField('Email', emailController, readOnly: true),
                  _buildTextField('Nomor Telepon', phoneController),
                  _buildTextField('Alamat', addressController),
                  // _buildTextField('Password', passwordController),
                  _buildTextField('Password Lama', oldPasswordController),
                  _buildTextField('Password Baru', newPasswordController),


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
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () async {
  String userId = userData['id'];
  String oldPassword = oldPasswordController.text.trim();
  String newPassword = newPasswordController.text.trim();
  String email = emailController.text.trim();

  // Update data profil ke Firebase Realtime Database
  DatabaseReference userRef = FirebaseDatabase.instance.ref().child('User').child(userId);

  await userRef.update({
    'name': nameController.text.trim(),
    'nomor_telepon': phoneController.text.trim(),
    'alamat': addressController.text.trim(),
    if (newPassword.isNotEmpty) 'password': newPassword,
  });

  // 🔐 Update password di Firebase Authentication (jika ini user yang sedang login)
  if (newPassword.isNotEmpty) {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.email == email) {
        // 🔐 Re-authenticate sebelum ubah password
        final cred = EmailAuthProvider.credential(
          email: email,
          password: oldPassword,
        );

        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(newPassword);

        // Optional: tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password berhasil diubah di Authentication")),
        );
      }
    } catch (e) {
      debugPrint("Gagal ubah password: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengubah password di Authentication")),
      );
    }
  }

  Navigator.pop(context);
  _fetchUsersFromFirebase();
},


                child: const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.amber),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber),
          ),
        ),
      ),
    );
  }
}
