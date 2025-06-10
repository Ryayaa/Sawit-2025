import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const EditProfilApp());
}

class EditProfilApp extends StatelessWidget {
  const EditProfilApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Profil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 255, 255)),
      ),
      home: const EditProfilPage(),
    );
  }
}

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({Key? key}) : super(key: key);

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(text: '*************');
  final TextEditingController _nomor_teleponController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String uid = '';
  String displayName = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
  User? user = _auth.currentUser;

  if (user != null) {
    uid = user.uid;
    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['name'] ?? ''; // ganti ke 'name'
        _emailController.text = user.email ?? '';
        _nomor_teleponController.text = data['nomor_telepon'] ?? '';
        _alamatController.text = data['alamat'] ?? '';
        displayName = data['name'] ?? ''; // juga ganti ke 'name'
      });
    }
  }
}



  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nomor_teleponController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3A7D44);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Edit Profil",
          style: TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, size: 50, color: primaryColor),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.white, blurRadius: 4)],
                      ),
                      padding: const EdgeInsets.all(5),
                      child: const Icon(Icons.camera_alt, size: 16, color: primaryColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primaryColor)),
            const SizedBox(height: 24),
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField('Nama', _nameController, icon: Icons.person),
                      _buildTextField('Email', _emailController, icon: Icons.email, inputType: TextInputType.emailAddress),
                      _buildTextField('Password', _passwordController, icon: Icons.lock, isPassword: true),
                      _buildTextField('No. Telp', _nomor_teleponController, icon: Icons.phone, inputType: TextInputType.phone),
                      _buildTextField('Alamat', _alamatController, icon: Icons.location_on),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 2,
                          ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await _firestore.collection('users').doc(uid).update({
                                  'name': _nameController.text, // harus sama: 'name'
                                  'nomor_telepon': _nomor_teleponController.text,
                                  'alamat': _alamatController.text,
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Profil disimpan!")),
                                );
                              }
                            },

                          icon: const Icon(Icons.save_alt_rounded, size: 20),
                          label: const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Note: Untuk mengubah password anda perlu verifikasi email terlebih dahulu',
              style: TextStyle(fontSize: 11, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        obscureText: isPassword,
        style: const TextStyle(color: Color(0xFF3A7D44)),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Color(0xFF3A7D44)) : null,
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF3A7D44)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF3A7D44)),
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Field tidak boleh kosong' : null,
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? Color(0xFF3A7D44) : Colors.grey, size: 26),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: active ? Color(0xFF3A7D44) : Colors.grey, fontSize: 12, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
