import 'package:flutter/material.dart';
import 'package:admin/screens/profil/editprofilpage.dart';
import 'package:admin/screens/widgets/profile_row.dart';
import 'package:admin/screens/main/components/side_menu.dart';
import 'package:admin/screens/dashboard/dashboard_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  static const primaryColor = Color(0xFF2A2D3E);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: const SideMenu(), // <--- INI YANG MEMUNCULKAN DRAWER DI PROFIL
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false, // <-- Supaya leading custom tampil
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF3A7D44)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Profil',
            style: TextStyle(
              color: Color(0xFF3A7D44),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildProfileCard(context),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48, bottom: 24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                backgroundImage: const AssetImage("assets/images/profile_pic.png"),
                child: const Icon(Icons.person, size: 48, color: Color(0xFF3A7D44)),
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
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.camera_alt, size: 18, color: Color(0xFFF27329)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sutan B.R',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFFF27329),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Verified",
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profil Saya',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF3A7D44),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            // Email
            Row(
              children: [
                Icon(Icons.email_outlined, color: Colors.blueGrey[400], size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Email", style: TextStyle(fontSize: 11, color: Colors.black54)),
                      Text("sutan@email.com", style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 16, color: Color(0xFFF27329)),
                  label: const Text("CHANGE", style: TextStyle(fontSize: 12, color: Color(0xFFF27329))),
                  style: TextButton.styleFrom(
                    minimumSize: Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1, color: Color(0xFFF0F1F6)),
            // No HP
            Row(
              children: [
                Icon(Icons.phone_android, color: Colors.blueGrey[400], size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("No HP", style: TextStyle(fontSize: 11, color: Colors.black54)),
                      Text("089680510618", style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1, color: Color(0xFFF0F1F6)),
            // Alamat
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.home_outlined, color: Colors.blueGrey[400], size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Alamat", style: TextStyle(fontSize: 11, color: Colors.black54)),
                      Text(
                        "Jl. Sungai Andai Komplek Herlina Perkasa",
                        style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1, color: Color(0xFFF0F1F6)),
            // Password
            Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.blueGrey[400], size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Password", style: TextStyle(fontSize: 11, color: Colors.black54)),
                      const Text("********", style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 16, color: Color(0xFFF27329)),
                  label: const Text("CHANGE", style: TextStyle(fontSize: 12, color: Color(0xFFF27329))),
                  style: TextButton.styleFrom(
                    minimumSize: Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfilPage()),
                  );
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit Profil', style: TextStyle(fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  backgroundColor: const Color(0xFF3A7D44),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
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
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (active)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF27329).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
              ),
            Icon(icon, color: active ? const Color(0xFFF27329) : Colors.grey, size: 26),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: active ? const Color(0xFFF27329) : Colors.grey, fontSize: 12, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            color: const Color(0xFF3A7D44),
            width: double.infinity,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: const AssetImage("assets/images/profile_pic.png"),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Sutan B.R",
                  style: TextStyle(
                    color: Color(0xFF3A7D44),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "089680510618",
                  style: TextStyle(
                    color: Color(0xFF3A7D44),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDrawerItem(
                  context,
                  title: "Home",
                  icon: Icons.home,
                  routeName: '/home',
                ),
                _buildDrawerItem(
                  context,
                  title: "Location",
                  icon: Icons.location_on,
                  routeName: '/location',
                ),
                _buildDrawerItem(
                  context,
                  title: "Profil",
                  icon: Icons.person,
                  routeName: '/profil',
                  isSelected: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDrawerItem(context, title: "Settings", icon: Icons.settings, routeName: '/settings'),
          _buildDrawerItem(context, title: "Help", icon: Icons.help, routeName: '/help'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            child: Column(
              children: [
                const Text(
                  "Version 1.0.0",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                const Text(
                  "© 2023 Your Company",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required String title, required IconData icon, required String routeName, bool isSelected = false}) {
    return InkWell(
      onTap: () {
        if (ModalRoute.of(context)?.settings.name != routeName) {
          Navigator.pushNamed(context, routeName);
        } else {
          Navigator.pop(context); // hanya tutup drawer jika sudah di halaman itu
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF27329).withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFFF27329) : Colors.black54, size: 20),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFFF27329) : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

