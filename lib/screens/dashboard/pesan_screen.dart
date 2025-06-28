import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin/screens/main/components/side_menu.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:provider/provider.dart';
import '../dashboard/components/header.dart';

const kPrimaryColor = Color(0xFF3A7D44);
const kAccentColor = Color(0xFF91C788);
const kCardBackground = Color(0xFFF9F9F9);
const kShadowColor = Color(0xFFE0E0E0);
const double defaultPadding = 16.0;

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

  Future<void> _markAsRead(String uid) async {
    await _pesanRef.child(uid).update({'status': 'sudah_dibaca'});
    await _loadPesan();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Status diubah menjadi 'sudah_dibaca'")),
      );
    }
  }

  Widget _buildPesanCard(Map<String, dynamic> pesan, bool isDesktop) {
    final bool belumDibaca = pesan['status'] == 'belum_dibaca';
    return InkWell(
      onTap: () {
        if (belumDibaca) _markAsRead(pesan['uid']);
      },
      child: Card(
        elevation: 3,
        margin: EdgeInsets.symmetric(
          horizontal: isDesktop ? 8 : 0,
          vertical: 8,
        ),
        color: kCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: kShadowColor.withOpacity(0.3),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 20 : 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon status
              Container(
                decoration: BoxDecoration(
                  color: belumDibaca ? kPrimaryColor : kAccentColor,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.mail_outline_rounded,
                  color: Colors.white,
                  size: isDesktop ? 28 : 22,
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pesan['email'] ?? 'Tanpa Email',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 16 : 14,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.person, size: 13, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          "UID: ${pesan['uid']}",
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 13, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          pesan['waktu'],
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      pesan['pesan'],
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: belumDibaca ? Colors.red[100] : Colors.green[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: belumDibaca ? Colors.red : Colors.green,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                belumDibaca ? Icons.mark_email_unread : Icons.mark_email_read,
                                color: belumDibaca ? Colors.red : Colors.green,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                pesan['status'].toString().toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: belumDibaca ? Colors.red[800] : Colors.green[800],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (belumDibaca)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              "Tap untuk tandai sudah dibaca",
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
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
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: const SideMenu(),
      backgroundColor: const Color(0xFFF5F6FA),
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
                    const Header(title: "Pesan Reset Password"),
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
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : pesanList.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 40),
                                    child: Text(
                                      "Tidak ada pesan.",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: pesanList.length,
                                  itemBuilder: (context, index) {
                                    return _buildPesanCard(pesanList[index], isDesktop);
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
}
