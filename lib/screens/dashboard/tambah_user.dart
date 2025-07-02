import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class TambahUser extends StatefulWidget {
  const TambahUser({Key? key}) : super(key: key);

  @override
  State<TambahUser> createState() => _TambahUserState();
}

class _TambahUserState extends State<TambahUser> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _alamatController = TextEditingController();
  final _teleponController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerUser() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    // 1. Buat user di Firebase Auth
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // 2. Dapatkan UID user
    final uid = userCredential.user!.uid;

    // 3. Simpan data user ke Realtime Database
    await FirebaseDatabase.instance.ref('User/$uid').set({
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "alamat": _alamatController.text.trim(),
      "nomor_telepon": _teleponController.text.trim(),
      "password": _passwordController.text.trim(), // Opsional
      "role": 2,
    });

    // 4. Tampilkan notifikasi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User berhasil ditambahkan')),
    );

    _formKey.currentState?.reset();
  } on FirebaseAuthException catch (e) {
    // 5. Tangani error Firebase Auth
    String message = 'Terjadi kesalahan';
    if (e.code == 'email-already-in-use') {
      message = 'Email sudah digunakan';
    } else if (e.code == 'invalid-email') {
      message = 'Email tidak valid';
    } else if (e.code == 'weak-password') {
      message = 'Password terlalu lemah';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah User Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (value) => value!.isEmpty ? 'Masukkan nama' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Masukkan email' : null,
              ),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
                validator: (value) => value!.isEmpty ? 'Masukkan alamat' : null,
              ),
              TextFormField(
                controller: _teleponController,
                decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Masukkan nomor telepon' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Minimal 6 karakter' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Tambah User'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
