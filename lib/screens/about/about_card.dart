import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutCard extends StatelessWidget {
  final String name, photo, instagram, github, linkedin;

  const AboutCard({
    super.key,
    required this.name,
    required this.photo,
    required this.instagram,
    required this.github,
    required this.linkedin,
  });

  void _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  String _getUsername(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last.replaceAll('/', '');
      }
      return url;
    } catch (_) {
      return url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Card(
      color: const Color(0xFFE8F5E9),
      margin: EdgeInsets.symmetric(
        vertical: isMobile ? 10 : 18,
        horizontal: isMobile ? 4 : 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto profil dengan border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF3A7D44), width: 3),
              ),
              child: CircleAvatar(
                backgroundImage: AssetImage(photo),
                radius: isMobile ? 32 : 40,
              ),
            ),
            SizedBox(width: isMobile ? 14 : 28),
            // Nama dan sosial media
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 18 : 22,
                      color: const Color(0xFF256029),
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 2,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Instagram
                  Tooltip(
                    message: "Instagram",
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => _launchUrl(instagram),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/instagram.svg",
                            width: isMobile ? 22 : 26,
                            height: isMobile ? 22 : 26,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getUsername(instagram),
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 15,
                              color: Colors.purple[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // GitHub
                  Tooltip(
                    message: "GitHub",
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => _launchUrl(github),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/github.svg",
                            width: isMobile ? 22 : 26,
                            height: isMobile ? 22 : 26,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getUsername(github),
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // LinkedIn
                  Tooltip(
                    message: "LinkedIn",
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => _launchUrl(linkedin),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/linkedin.svg",
                            width: isMobile ? 22 : 26,
                            height: isMobile ? 22 : 26,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getUsername(linkedin),
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 15,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
