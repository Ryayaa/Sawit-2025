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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Widget suhu terkini
          Expanded(
            child: Row(
              children: [
                SvgPicture.asset(
                  "assets/icons/temperature.svg",
                  height: 36,
                  width: 36,
                  color: Colors.orangeAccent,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Suhu Terkini",
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "$suhuTerkini°C",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          // Widget cuaca besok
          Expanded(
            child: Row(
              children: [
                SvgPicture.asset(
                  "assets/icons/weather.svg",
                  height: 36,
                  width: 36,
                  color: Colors.lightBlueAccent,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ramalan Besok",
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      ramalanBesok,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
