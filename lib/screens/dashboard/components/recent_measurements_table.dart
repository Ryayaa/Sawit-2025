import 'package:flutter/material.dart';

class RecentMeasurementsTable extends StatelessWidget {
  final List<Map<String, dynamic>> initialMeasurements;

  const RecentMeasurementsTable({
    Key? key,
    required this.initialMeasurements,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Data Terbaru",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 12),
            Table(
              columnWidths: const {
                0: FixedColumnWidth(90),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
              },
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.grey),
              ),
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text("Modul",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                          textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text("Suhu (°C)",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                          textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text("Kelembapan (%)",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                          textAlign: TextAlign.center),
                    ),
                  ],
                ),
                // Data rows dengan zebra effect dan icon
                ...initialMeasurements.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final data = entry.value;
                  return TableRow(
                    decoration: BoxDecoration(
                      color: idx.isEven ? Colors.white : const Color(0xFFF5F6FA),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.memory, size: 18, color: Colors.green[700]),
                            const SizedBox(width: 6),
                            Text(
                              data['module'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black87, // warna hitam/abu gelap
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          data['temperature'].toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black87, // warna hitam/abu gelap
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          data['soilMoisture'].toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black87, // warna hitam/abu gelap
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
