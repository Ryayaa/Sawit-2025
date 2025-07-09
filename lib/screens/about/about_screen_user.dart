import 'package:flutter/material.dart';
import '../main/components/side_menu_user.dart';
import '../dashboard/components/header_user.dart';

import 'about_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:provider/provider.dart';

class AboutScreenUser extends StatelessWidget {
  const AboutScreenUser({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> team = [
      {
        "name": "Arrya Fitriansyah",
        "photo": "assets/images/Arrya.png",
        "instagram": "https://instagram.com/aryya_",
        "github": "https://github.com/Ryayaa",
        "linkedin": "https://linkedin.com/in/arrya-fitriansyah",
      },
      {
        "name": "Aldi Riadi",
        "photo": "assets/images/Aldi.png",
        "instagram": "https://instagram.com/aldiriadi23",
        "github": "https://github.com/aldiriadi23",
        "linkedin": "https://linkedin.com/in/aldiriadi23",
      },
      {
        "name": "Sutan Burhan Rasyidin",
        "photo": "assets/images/Sutan.png",
        "instagram": "https://instagram.com/sutanburhanr",
        "github": "https://github.com/sutanbr",
        "linkedin": "https://linkedin.com/in/sutan-burhan-rasyidin",
      },
    ];

    final isMobile = !Responsive.isDesktop(context);

    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: isMobile ? const SideMenuUser() : null,
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile) const Expanded(flex: 1, child: SideMenuUser()),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 32, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeaderUser(title: "About Developer"),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: isMobile ? 18 : 32,
                                  bottom: isMobile ? 18 : 32),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  const url = "https://poliban.ac.id";
                                  if (await canLaunchUrl(Uri.parse(url))) {
                                    await launchUrl(Uri.parse(url),
                                        mode: LaunchMode.externalApplication);
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/logo_poliban.svg",
                                      width: isMobile ? 38 : 48,
                                      height: isMobile ? 38 : 48,
                                    ),
                                    const SizedBox(width: 14),
                                    Text(
                                      "Politeknik Negeri Banjarmasin",
                                      style: TextStyle(
                                        fontSize: isMobile ? 16 : 22,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF256029),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Tambahkan penjelasan di sini, sebelum ListView.separated
                            SizedBox(height: isMobile ? 10 : 18),
                            Card(
                              color: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 16 : 28,
                                  vertical: isMobile ? 12 : 18,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Aplikasi ini dibuat oleh tiga mahasiswa Politeknik Negeri Banjarmasin sebagai bagian dari Tugas Akhir.",
                                      style: TextStyle(
                                        fontSize: isMobile ? 13 : 15,
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "Seluruh fitur, desain, dan pengembangan aplikasi ini merupakan hasil kolaborasi tim demi mendukung inovasi dan kemajuan teknologi di lingkungan kampus.",
                                      style: TextStyle(
                                        fontSize: isMobile ? 12 : 14,
                                        color: Colors.grey[600],
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 10 : 18),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 4 : 16,
                                vertical: isMobile ? 8 : 16,
                              ),
                              itemCount: team.length,
                              separatorBuilder: (context, i) =>
                                  SizedBox(height: isMobile ? 12 : 22),
                              itemBuilder: (context, i) => AboutCard(
                                name: team[i]["name"]!,
                                photo: team[i]["photo"]!,
                                instagram: team[i]["instagram"]!,
                                github: team[i]["github"]!,
                                linkedin: team[i]["linkedin"]!,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: isMobile ? 10 : 18,
                                  top: isMobile ? 10 : 18),
                              child: Text(
                                "© 2025 Sawit Team • All Rights Reserved",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: isMobile ? 11 : 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
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
