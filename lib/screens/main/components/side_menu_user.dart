import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:admin/screens/profil/profil_user.dart';

import '../../../screens/dashboard/dashboard_user.dart';
import 'package:provider/provider.dart';
import '../../../controllers/menu_app_controller.dart';

class SideMenuUser extends StatelessWidget {
  const SideMenuUser({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: const Color.fromARGB(28, 28, 46, 255),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100, // Ukuran lebar logo agar tidak terlalu besar
                  height: 100, // Tinggi juga dibatasi agar seimbang
                  child: Image.asset("assets/images/logo1sawit.png"),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "I-Sawit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20, // Ukuran font yang proporsional
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider(
                        create: (context) => MenuAppController(),
                      ),
                    ],
                    child: DashboardUser(), // Removed const here
                  ),
                ),
              );
            },
          ),
         
          DrawerListTile(
            title: "Profil",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileUserPage()),
              );
            },
          ),
          // DrawerListTile(
          //   title: "Notification",
          //   svgSrc: "assets/icons/menu_notification.svg",
          //   press: () {},
          // ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
