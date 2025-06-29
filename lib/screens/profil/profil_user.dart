import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:admin/screens/widgets/profile_row.dart';
import 'package:admin/screens/main/components/side_menu_user.dart';

const kPrimaryColor = Color(0xFF3A7D44);
const kAccentColor = Color(0xFF91C788);
const kCardBackground = Color(0xFFF9F9F9);
const kShadowColor = Color(0xFFE0E0E0);

class ProfileUserPage extends StatefulWidget {
  const ProfileUserPage({Key? key}) : super(key: key);

  @override
  State<ProfileUserPage> createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUserPage> {
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
  final newPasswordController = TextEditingController();
  bool _obscurePassword = true;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Reset Password"),
          content: TextField(
            controller: newPasswordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password Baru',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Ubah"),
              onPressed: () async {
                final newPassword = newPasswordController.text.trim();
                final user = FirebaseAuth.instance.currentUser;

                if (newPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password tidak boleh kosong")),
                  );
                  return;
                }

                try {
                  await user?.updatePassword(newPassword);
                  final uid = user?.uid;

                  if (uid != null) {
                    await FirebaseDatabase.instance.ref()
                        .child('User')
                        .child(uid)
                        .update({'password': newPassword});
                  }

                  Navigator.of(context).pop();

                  showDialog(
                    context: context,
                    useRootNavigator: true,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text("Berhasil"),
                        content: const Text("Password berhasil diubah."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text("OK"),
                          )
                        ],
                      );
                    },
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal update password: $e")),
                  );
                }
              },
            ),
          ],
        ),
      );
    },
  );
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCardBackground, // Ubah warna background
      bottomNavigationBar: _buildBottomNavBar(),
      drawer: const SideMenuUser(),
      body: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildProfileCard(context),
        ],
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kAccentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.only(top: 50, bottom: 40),
      child: Stack(
        children: [
          // Tombol menu harus warna putih dan selalu di atas
          Positioned(
            left: 16,
            top: 1,
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu,
                    color: Colors.white), // GANTI jadi putih
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: 'Menu',
              ),
            ),
          ),
          // Konten header di tengah
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: kPrimaryColor, width: 3),
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
                        color: kPrimaryColor)), // Ubah warna judul
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
