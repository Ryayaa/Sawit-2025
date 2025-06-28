import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../controllers/menu_app_controller.dart';
import '../../../screens/dashboard/dashboard_user.dart';
import '../../../screens/profil/profil_user.dart';

// Konstanta warna dashboard
const kPrimaryColor = Color(0xFF3A7D44);
const kAccentColor = Color(0xFF91C788);
const kCardBackground = Color(0xFFF9F9F9);
const kShadowColor = Color(0xFFE0E0E0);

class SideMenuUser extends StatelessWidget {
  const SideMenuUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    return Drawer(
      backgroundColor: kCardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(32)),
      ),
      child: Container(
        color: kCardBackground,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _DrawerHeaderUser(),
            const SizedBox(height: 8),
            DrawerListTileUser(
              title: "Dashboard",
              svgSrc: "assets/icons/menu_dashboard.svg",
              routeName: '/dashboard_user',
              selected: currentRoute == '/dashboard_user',
              press: () {
                if (currentRoute != '/dashboard_user') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider(
                            create: (context) => MenuAppController(),
                          ),
                        ],
                        child: const DashboardUser(),
                      ),
                    ),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            DrawerListTileUser(
              title: "Profil",
              svgSrc: "assets/icons/menu_profile.svg",
              routeName: '/profil_user',
              selected: currentRoute == '/profil_user',
              press: () {
                if (currentRoute != '/profil_user') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileUserPage()),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            // Tambahkan menu lain jika perlu
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeaderUser extends StatelessWidget {
  const _DrawerHeaderUser();

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: kCardBackground,
        boxShadow: [
          BoxShadow(
            color: kShadowColor,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [kPrimaryColor, kAccentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: kShadowColor,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 32,
              backgroundColor: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Image(
                  image: AssetImage("assets/images/logo1sawit.png"),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Flexible(
            child: Text(
              "I-Sawit",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: kPrimaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerListTileUser extends StatelessWidget {
  const DrawerListTileUser({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.press,
    required this.routeName,
    this.selected = false,
  }) : super(key: key);

  final String title, svgSrc, routeName;
  final VoidCallback press;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? kAccentColor.withOpacity(0.18) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          onTap: press,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          leading: Container(
            decoration: BoxDecoration(
              color: selected ? kPrimaryColor : kCardBackground,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              svgSrc,
              colorFilter: ColorFilter.mode(
                selected ? Colors.white : kPrimaryColor,
                BlendMode.srcIn,
              ),
              height: 20,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: selected ? kPrimaryColor : Colors.black87,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
          horizontalTitleGap: 12,
        ),
      ),
    );
  }
}
