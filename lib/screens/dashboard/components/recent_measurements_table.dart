import 'package:flutter/material.dart';
import '../../../services/firebase_service.dart';
import '../../../models/sensor_reading.dart';

class RecentMeasurementsTable extends StatefulWidget {
  const RecentMeasurementsTable({Key? key}) : super(key: key);

  @override
  State<RecentMeasurementsTable> createState() =>
      _RecentMeasurementsTableState();
}

class _RecentMeasurementsTableState extends State<RecentMeasurementsTable> {
  final int itemsPerPage = 10;
  int _currentPage = 0;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final double fontSize = isMobile ? 12 : 14;
    final double headerFontSize = isMobile ? 13 : 16;
    final EdgeInsetsGeometry cellPadding = isMobile
        ? const EdgeInsets.symmetric(vertical: 8, horizontal: 4)
        : const EdgeInsets.symmetric(vertical: 12, horizontal: 12);

    return StreamBuilder<Map<String, List<SensorReading>>>(
      stream: _firebaseService.getAllModulesData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Ambil data terbaru dari setiap modul
        final List<Map<String, dynamic>> measurements = [];
        snapshot.data!.forEach((moduleId, readings) {
          if (readings.isNotEmpty) {
            final latest = readings.last;
            measurements.add({
              'module': moduleId,
              'temperature': latest.temperature,
              'humidity': latest.humidity,
            });
          }
        });

        // Urutkan berdasarkan nama modul
        measurements.sort(
            (a, b) => a['module'].toString().compareTo(b['module'].toString()));

        final int totalPages = (measurements.length / itemsPerPage).ceil();
        final int startIndex = _currentPage * itemsPerPage;
        final int endIndex = (startIndex + itemsPerPage > measurements.length)
            ? measurements.length
            : startIndex + itemsPerPage;

        if (measurements.isEmpty) {
          return const Center(child: Text('Tidak ada data terbaru.'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: isMobile
                  ? const EdgeInsets.only(left: 8, top: 8, bottom: 8)
                  : const EdgeInsets.only(left: 16, top: 16, bottom: 16),
              child: Text(
                "Data Terbaru",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 18 : 22,
                  color: Colors.black87,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: isMobile ? 16 : 32,
                headingRowColor:
                    MaterialStateProperty.all(Colors.blue.shade100),
                columns: [
                  DataColumn(
                    label: Padding(
                      padding: cellPadding,
                      child: Text('Modul',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: headerFontSize)),
                    ),
                  ),
                  DataColumn(
                    label: Padding(
                      padding: cellPadding,
                      child: Text('Suhu (°C)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: headerFontSize)),
                    ),
                  ),
                  DataColumn(
                    label: Padding(
                      padding: cellPadding,
                      child: Text('Kelembapan (%)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: headerFontSize)),
                    ),
                  ),
                ],
                rows: measurements
                    .sublist(startIndex, endIndex)
                    .map(
                      (data) => DataRow(
                        cells: [
                          DataCell(
                            Padding(
                              padding: cellPadding,
                              child: Row(
                                children: [
                                  Icon(Icons.memory,
                                      size: isMobile ? 16 : 20,
                                      color: Colors.green.shade700),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      data['module'].toString(),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontSize: fontSize,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataCell(
                            Padding(
                              padding: cellPadding,
                              child: Text(
                                "${data['temperature']}°",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.redAccent,
                                  fontSize: fontSize,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Padding(
                              padding: cellPadding,
                              child: Text(
                                "${data['humidity']}%",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blueAccent,
                                  fontSize: fontSize,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            PaginationControls(
              currentPage: _currentPage,
              totalPages: totalPages,
              onPageChanged: (page) => setState(() => _currentPage = page),
            ),
          ],
        );
      },
    );
  }
}

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const PaginationControls({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed:
              currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
          color: Colors.blue,
        ),
        Text(
          'Halaman ${currentPage + 1} dari $totalPages',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: currentPage < totalPages - 1
              ? () => onPageChanged(currentPage + 1)
              : null,
          color: Colors.blue,
        ),
      ],
    );
  }
}
