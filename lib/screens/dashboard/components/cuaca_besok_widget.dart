import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Pastikan package ini sudah ditambahkan

class CuacaBesokWidget extends StatelessWidget {
  final String suhuTerkini;
  final String ramalanBesok;

  const CuacaBesokWidget({
    Key? key,
    required this.suhuTerkini,
    required this.ramalanBesok,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Suhu terkini
          Expanded(
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(
                    "assets/icons/temperature.svg",
                    height: 28,
                    width: 28,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Suhu Terkini",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      "$suhuTerkini°C",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 18, // dari 22 jadi 18
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          // Divider vertikal
          Container(
            width: 1,
            height: 48,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),
          // Ramalan besok
          Expanded(
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(
                    "assets/icons/weather.svg",
                    height: 28,
                    width: 28,
                    color: Colors.lightBlue,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ramalan Besok",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      ramalanBesok,
                      style: const TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 15, // dari 18 jadi 15
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
