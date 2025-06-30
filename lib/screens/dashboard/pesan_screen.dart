import 'package:flutter/material.dart';

class PesanScreen extends StatelessWidget {
  const PesanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesan')),
      body: const Center(child: Text('Halaman Pesan')),
    );
  }
}