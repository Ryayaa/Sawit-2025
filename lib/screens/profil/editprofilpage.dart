import 'package:flutter/material.dart';

void main() {
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

  final TextEditingController _namaController = TextEditingController(text: 'Sutan B.R');
  final TextEditingController _emailController = TextEditingController(text: 'sutan***@gmail.com');
  final TextEditingController _passwordController = TextEditingController(text: '*************');
  final TextEditingController _telpController = TextEditingController(text: '089680510618');
  final TextEditingController _alamatController = TextEditingController(text: 'Jl. Sungai Andai Komplek Herlina Perkasa');

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _telpController.dispose();
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
            // Avatar dengan tombol ubah foto
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
                    onTap: () {
                      // TODO: aksi ubah foto
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: const Color.fromARGB(255, 255, 255, 255), blurRadius: 4)],
                      ),
                      padding: const EdgeInsets.all(5),
                      child: const Icon(Icons.camera_alt, size: 16, color: primaryColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Sutan B.R', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primaryColor)),
            const SizedBox(height: 24),
            // Card Form
            Card(
              color: Colors.white, // <-- pastikan baris ini ada
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField('Nama', _namaController, icon: Icons.person),
                      _buildTextField('Email', _emailController, icon: Icons.email, inputType: TextInputType.emailAddress),
                      _buildTextField('Password', _passwordController, icon: Icons.lock, isPassword: true),
                      _buildTextField('No. Telp', _telpController, icon: Icons.phone, inputType: TextInputType.phone),
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
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
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
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home, "Home", false),
              _buildNavItem(Icons.location_on, "Location", false),
              _buildNavItem(Icons.person, "Profil", true),
            ],
          ),
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
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16), // tambah ini
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
