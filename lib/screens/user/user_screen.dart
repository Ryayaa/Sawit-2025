import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin/screens/main/components/side_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:provider/provider.dart';
import '../dashboard/components/header.dart';

const kPrimaryColor = Color(0xFF3A7D44);
const kAccentColor = Color(0xFF91C788);
const kCardBackground = Color(0xFFF9F9F9);
const kShadowColor = Color(0xFFE0E0E0);
const double defaultPadding = 16.0;

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
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: const SideMenu(),
      backgroundColor: kCardBackground,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop)
              const Expanded(flex: 1, child: SideMenu()),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Header(title: "Data User"),
                    const SizedBox(height: defaultPadding),
                    Container(
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _userList.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _userList.length,
                              itemBuilder: (context, index) {
                                final user = _userList[index];
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  child: Card(
                                    color: kCardBackground,
                                    elevation: 2,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: isDesktop ? 16 : 0,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    shadowColor: kShadowColor,
                                    child: Theme(
                                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                      child: ExpansionTile(
                                        leading: CircleAvatar(
                                          backgroundColor: kAccentColor,
                                          child: Icon(Icons.person, color: kPrimaryColor),
                                        ),
                                        iconColor: kPrimaryColor,
                                        collapsedIconColor: kPrimaryColor,
                                        textColor: kPrimaryColor,
                                        collapsedTextColor: Colors.black87,
                                        title: Text(
                                          user['name'],
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: kPrimaryColor),
                                        ),
                                        subtitle: Text(user['email'], style: const TextStyle(color: Colors.black54)),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.phone, color: kAccentColor, size: 18),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      user['nomor_telepon'],
                                                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.home, color: kAccentColor, size: 18),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        user['alamat'],
                                                        style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Chip(
                                                  label: Text(
                                                    "Role: ${user['role']}",
                                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                  ),
                                                  backgroundColor: kPrimaryColor,
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
                                                icon: const Icon(Icons.edit, color: kAccentColor),
                                                label: const Text('Edit', style: TextStyle(color: kAccentColor)),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: kPrimaryColor,
                                                  overlayColor: kAccentColor.withOpacity(0.1),
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> userData) {
    TextEditingController nameController = TextEditingController(text: userData['name']);
    TextEditingController emailController = TextEditingController(text: userData['email']);
    TextEditingController phoneController = TextEditingController(text: userData['nomor_telepon']);
    TextEditingController addressController = TextEditingController(text: userData['alamat']);
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Edit Data User', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 18),
                  _buildTextField('Name', nameController),
                  _buildTextField('Email', emailController, readOnly: true),
                  _buildTextField('Nomor Telepon', phoneController),
                  _buildTextField('Alamat', addressController),
                  _buildTextField('Password Lama', oldPasswordController),
                  _buildTextField('Password Baru', newPasswordController),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Batal', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        icon: const Icon(Icons.save_alt_rounded, size: 18),
                        label: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: kPrimaryColor),
          filled: true,
          fillColor: kCardBackground,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kAccentColor.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: kPrimaryColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
