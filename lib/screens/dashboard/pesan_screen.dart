import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PesanScreen extends StatefulWidget {
  const PesanScreen({Key? key}) : super(key: key);

  @override
  State<PesanScreen> createState() => _PesanScreenState();
}

class _PesanScreenState extends State<PesanScreen> {
  final DatabaseReference _pesanRef =
      FirebaseDatabase.instance.ref().child('PesanResetPassword');

  List<Map<String, dynamic>> pesanList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPesan();
  }

  Future<void> _loadPesan() async {
    final snapshot = await _pesanRef.get();

    final List<Map<String, dynamic>> loadedPesan = [];

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data.forEach((key, value) {
        loadedPesan.add({
          'email': value['email'] ?? '',
          'uid': value['uid'] ?? '',
          'status': value['status'] ?? '',
          'waktu': value['waktu'] ?? '',
          'pesan': value['pesan'] ?? '',
        });
      });
    }

    loadedPesan.sort((a, b) =>
        DateTime.parse(b['waktu']).compareTo(DateTime.parse(a['waktu'])));

    setState(() {
      pesanList = loadedPesan;
      isLoading = false;
    });
  }

  Widget _buildPesanCard(Map<String, dynamic> pesan) {
  return InkWell(
    onTap: () async {
      if (pesan['status'] == 'belum_dibaca') {
        final uid = pesan['uid'];
        await _pesanRef.child(uid).update({'status': 'sudah_dibaca'});
        _loadPesan(); // refresh data setelah update
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Status diubah menjadi 'sudah_dibaca'")),
        );
      }
    },
    child: Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
          pesan['email'] ?? 'Tanpa Email',
          style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "UID: ${pesan['uid']}",
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          "Waktu: ${pesan['waktu']}",
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          "Pesan: ${pesan['pesan']}", // Tambahkan baris ini untuk menampilkan pesan
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
          color: pesan['status'] == 'belum_dibaca'
            ? Colors.red[100]
            : Colors.green[100],
          borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
          pesan['status'].toString().toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: pesan['status'] == 'belum_dibaca'
              ? Colors.red[800]
              : Colors.green[800],
            fontSize: 12,
          ),
          ),
        ),
        ],
      ),
      ),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesan Reset Password"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pesanList.isEmpty
              ? const Center(child: Text("Tidak ada pesan."))
              : RefreshIndicator(
                  onRefresh: _loadPesan,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: pesanList.length,
                    itemBuilder: (context, index) {
                      return _buildPesanCard(pesanList[index]);
                    },
                  ),
                ),
    );
  }
}
