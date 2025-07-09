import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:admin/screens/profil/profil.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../constants.dart';

class Header extends StatelessWidget {
  final String title;
  const Header({
    Key? key,
    this.title = "Dashboard",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        const Spacer(),
        const ProfileCard(), // Gunakan const
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'profile') {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const ProfilePage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        } else if (value == 'logout') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Konfirmasi Logout'),
                content: const Text('Apakah Anda yakin ingin keluar?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Tambahkan signOut sebelum navigasi
                      await FirebaseAuth.instance.signOut();
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    child: const Text('Logout'),
                  ),
                ],
              );
            },
          );
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'profile',
          child: _ProfileMenuItem(),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: _LogoutMenuItem(),
        ),
      ],
      child: Container(
        margin: const EdgeInsets.only(left: defaultPadding),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 21,
            backgroundImage: AssetImage("assets/images/logosawit.png"),
            backgroundColor: Color(0xFFF5F5F5),
          ),
        ),
      ),
    );
  }
}

// Pisahkan menu item agar bisa const
class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.person_outline),
        SizedBox(width: 8),
        Text('Profile'),
      ],
    );
  }
}

class _LogoutMenuItem extends StatelessWidget {
  const _LogoutMenuItem();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.logout),
        SizedBox(width: 8),
        Text('Logout'),
      ],
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search",
        fillColor: secondaryColor,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(defaultPadding * 0.75),
            margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset("assets/icons/Search.svg"),
          ),
        ),
      ),
    );
  }
}
