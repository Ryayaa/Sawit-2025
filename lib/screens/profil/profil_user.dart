import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:admin/screens/profil/editprofilpage.dart' show EditProfilPage;
import 'package:admin/screens/widgets/profile_row.dart' show ProfileRow;
import 'package:admin/screens/main/components/side_menu_user.dart'; 

class ProfileUser extends StatefulWidget {
  const ProfileUser({Key? key}) : super(key: key);

  @override
  State<ProfileUser> createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('User');
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  print('Current UID: $uid');

  if (uid != null) {
    final snapshot = await _dbRef.child(uid).get();
    if (snapshot.exists) {
      print('Data snapshot: ${snapshot.value}');
      final data = Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);
      setState(() {
        userData = data;
      });
    } else {
      print('No data found for UID $uid');
    }
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF),
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
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white, size: 28),
              onPressed: () {},
              tooltip: 'Home',
            ),
            IconButton(
              icon: const Icon(Icons.location_on, color: Colors.white, size: 28),
              onPressed: () {},
              tooltip: 'Map',
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Cari', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.purpleAccent, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 50, bottom: 40),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 1,
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
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
                  child: const Icon(Icons.person, size: 50, color: Color.fromARGB(255, 59, 55, 55)),
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
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 16),
                ProfileRow(label: 'EMAIL', value: userData?['email'] ?? '', actionText: 'CHANGE'),
                ProfileRow(label: 'NO HP', value: userData?['nomor_telepon'] ?? '-', actionText: ''),
                ProfileRow(label: 'ALAMAT', value: userData?['alamat'] ?? '-', actionText: ''),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 400),
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const EditProfilPage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            final offsetAnimation = Tween<Offset>(
                              begin: const Offset(0.0, 1.0),
                              end: Offset.zero,
                            ).animate(animation);
                            final fadeAnimation = Tween<double>(
                              begin: 0.0,
                              end: 1.0,
                            ).animate(animation);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: FadeTransition(opacity: fadeAnimation, child: child),
                            );
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit Profil', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}