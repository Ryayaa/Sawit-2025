import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import '../../../screens/dashboard/dashboard_user.dart';
// import '../../../screens/profil/profil_user.dart';
// import '../../../screens/history/user_history_screen.dart';

class SideMenuUser extends StatelessWidget {
  const SideMenuUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    return Drawer(
      backgroundColor: const Color(0xFFF1F1F1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(32)),
      ),
      child: Container(
        color: const Color(0xFFF5F6FA),
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
                  Navigator.pushReplacementNamed(context, '/dashboard_user');
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
                  Navigator.pushNamed(context, '/profil_user');
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            DrawerListTileUser(
              title: "History",
              svgSrc: "assets/icons/menu_doc.svg",
              routeName: '/user_history',
              selected: currentRoute == '/user_history',
              press: () {
                if (currentRoute != '/user_history') {
                  Navigator.pushReplacementNamed(context, '/user_history');
                } else {
                  Navigator.pop(context);
                }
              },
            ),
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
        color: Color(0xFFF1F1F1),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A3A7D44),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFF27329), Color(0xFF3A7D44)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33F27329),
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
                color: Color(0xFF3A7D44),
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
        color: selected ? const Color(0x1A3A7D44) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          onTap: press,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          leading: Container(
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF3A7D44) : const Color(0xFFF5F6FA),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              svgSrc,
              colorFilter: ColorFilter.mode(
                selected ? Colors.white : const Color(0xFF3A7D44),
                BlendMode.srcIn,
              ),
              height: 20,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: selected ? const Color(0xFF3A7D44) : Colors.black87,
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
