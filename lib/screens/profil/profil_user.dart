import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:admin/screens/widgets/profile_row.dart';
import 'package:admin/screens/main/components/side_menu_user.dart';

class ProfileUserPage extends StatefulWidget {
  const ProfileUserPage({Key? key}) : super(key: key);

  @override
  State<ProfileUserPage> createState() => _ProfileUserPageState();
}

class _ProfileUserPageState extends State<ProfileUserPage> {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child('User');
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final snapshot = await _dbRef.child(uid).get();
      if (snapshot.exists) {
        final data =
            Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);
        setState(() {
          userData = data;
        });
      }
    }
  }

  void _showResetPasswordDialog(BuildContext context) {
    String? verificationId;
    final otpController = TextEditingController();
    final newPasswordController = TextEditingController();
    final phoneNumber = userData?['nomor_telepon'];

    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nomor telepon tidak tersedia")),
      );
      return;
    }

    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verifikasi gagal: ${e.message}')),
        );
      },
      codeSent: (String verId, int? resendToken) {
        verificationId = verId;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Verifikasi OTP"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Masukkan kode OTP yang dikirim ke nomor Anda."),
                const SizedBox(height: 8),
                OTPTextField(
                  length: 6,
                  width: MediaQuery.of(context).size.width,
                  fieldWidth: 40,
                  style: const TextStyle(fontSize: 18),
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldStyle: FieldStyle.box,
                  onCompleted: (code) {
                    otpController.text = code;
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password Baru'),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Batal"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: const Text("Verifikasi & Ubah"),
                onPressed: () async {
                  if (otpController.text.length != 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Kode OTP harus 6 digit")),
                    );
                    return;
                  }

                  try {
                    final credential = PhoneAuthProvider.credential(
                      verificationId: verificationId!,
                      smsCode: otpController.text,
                    );

                    final user = FirebaseAuth.instance.currentUser;
                    await user?.reauthenticateWithCredential(credential);
                    await user
                        ?.updatePassword(newPasswordController.text.trim());

                    final uid = user!.uid;
                    await _dbRef.child(uid).update({
                      'password': newPasswordController.text.trim(),
                      'passwordTerakhirDiubah':
                          DateTime.now().toIso8601String(),
                    });

                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Berhasil"),
                        content: const Text("Password berhasil diubah."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          )
                        ],
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              "Gagal verifikasi atau update password: $e")),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const SideMenuUser(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF1F1F1)),
        title: const Text(
          "Profil",
          style: TextStyle(
            color: Color(0xFF3A7D44),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [],
        ),
      ),
    );
  }

  Widget _profileInfoRow(IconData icon, String label, String value) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purpleAccent, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 22),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/google_icon.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userData?['name'] ?? 'Loading...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: userData == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Profil Saya',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black87)),
                const SizedBox(height: 16),
                ProfileRow(
                    label: 'EMAIL',
                    value: userData?['email'] ?? '',
                    actionText: ''),
                ProfileRow(
                    label: 'NO HP',
                    value: userData?['nomor_telepon'] ?? '-',
                    actionText: ''),
                ProfileRow(
                    label: 'ALAMAT',
                    value: userData?['alamat'] ?? '-',
                    actionText: ''),
                ProfileRow(
                  label: 'PASSWORD',
                  value: '********',
                  actionText: 'RESET',
                  onActionTap: () {
                    _showResetPasswordDialog(context);
                  },
                ),
              ],
            ),
    );
  }
}
