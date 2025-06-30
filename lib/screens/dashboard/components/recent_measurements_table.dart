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

  String _formatModuleName(String moduleId) {
    // Ubah 'module1' jadi 'Module 1'
    if (moduleId.toLowerCase().startsWith('module')) {
      final number = moduleId.replaceAll(RegExp(r'[^0-9]'), '');
      return 'Module $number';
    }
    return moduleId;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final double fontSize = isMobile ? 12 : 15;
    final double headerFontSize = isMobile ? 14 : 18;
    final EdgeInsetsGeometry cellPadding = isMobile
        ? const EdgeInsets.symmetric(vertical: 8, horizontal: 6)
        : const EdgeInsets.symmetric(vertical: 14, horizontal: 16);

    return StreamBuilder<Map<String, List<SensorReading>>>(
      stream: _firebaseService.getAllModulesData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Ambil data terbaru dari setiap modul yang ada
        final List<Map<String, dynamic>> measurements = [];
        snapshot.data!.forEach((moduleId, readings) {
          if (readings.isNotEmpty) {
            readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            final latest = readings.first;
            measurements.add({
              'module': _formatModuleName(moduleId),
              'temperature': latest.temperature,
              'humidity': latest.humidity,
            });
          }
        });

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
                  fontSize: isMobile ? 18 : 24,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Card(
              margin: isMobile
                  ? const EdgeInsets.symmetric(horizontal: 4)
                  : const EdgeInsets.symmetric(horizontal: 16),
              elevation: isMobile ? 1 : 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: isMobile ? 350 : 600,
                  ),
                  child: DataTable(
                    columnSpacing: isMobile ? 16 : 32,
                    headingRowColor: MaterialStateProperty.all(
                        Colors.blue.shade50.withOpacity(0.7)),
                    dataRowColor: MaterialStateProperty.all(Colors.white),
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
              ),
            ),
            const SizedBox(height: 10),
            PaginationControls(
              currentPage: _currentPage,
              totalPages: totalPages,
              onPageChanged: (page) => setState(() => _currentPage = page),
              isMobile: isMobile,
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
  final bool isMobile;

  const PaginationControls({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();
    return Padding(
      padding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 8)
          : const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed:
                currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
            color: Colors.blue,
            splashRadius: isMobile ? 16 : 22,
          ),
          Text(
            'Halaman ${currentPage + 1} dari $totalPages',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
              fontSize: isMobile ? 12 : 15,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            onPressed: currentPage < totalPages - 1
                ? () => onPageChanged(currentPage + 1)
                : null,
            color: Colors.blue,
            splashRadius: isMobile ? 16 : 22,
          ),
        ],
      ),
    );
  }
}
