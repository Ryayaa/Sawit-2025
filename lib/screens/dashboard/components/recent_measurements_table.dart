import 'package:flutter/material.dart';

class RecentMeasurementsTable extends StatefulWidget {
  final List<Map<String, dynamic>> initialMeasurements;

  const RecentMeasurementsTable({
    Key? key,
    required this.initialMeasurements,
  }) : super(key: key);

  @override
  State<RecentMeasurementsTable> createState() =>
      _RecentMeasurementsTableState();
}

class _RecentMeasurementsTableState extends State<RecentMeasurementsTable> {
  final int itemsPerPage = 10;
  int _currentPage = 0;
  late List<Map<String, dynamic>> _measurements; // Tambahkan ini

  @override
  void initState() {
    super.initState();
    _measurements = widget.initialMeasurements;
  }

  @override
  void didUpdateWidget(RecentMeasurementsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMeasurements != oldWidget.initialMeasurements) {
      setState(() {
        _measurements = widget.initialMeasurements;
      });
    }
  }

  // Add pagination controls
  Widget buildPaginatedTable() {
    final int totalPages = (_measurements.length / itemsPerPage).ceil();
    final int startIndex = _currentPage * itemsPerPage;
    final int endIndex = (startIndex + itemsPerPage) > _measurements.length
        ? _measurements.length
        : startIndex + itemsPerPage;

    return Column(
      children: [
        DataTable(
          columns: const [
            DataColumn(label: Text('Modul')),
            DataColumn(label: Text('Suhu (°C)')),
            DataColumn(label: Text('Kelembapan (%)')),
          ],
          rows: _measurements
              .sublist(startIndex, endIndex)
              .map(
                (data) => DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          Icon(Icons.memory,
                              size: 18, color: Colors.green[700]),
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
                    DataCell(
                      Text(
                        data['temperature'].toString(),
                        style: const TextStyle(
                          color: Colors.black87, // warna hitam/abu gelap
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        data['soilMoisture'].toString(),
                        style: const TextStyle(
                          color: Colors.black87, // warna hitam/abu gelap
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
        PaginationControls(
          currentPage: _currentPage,
          totalPages: totalPages,
          onPageChanged: (page) => setState(() => _currentPage = page),
        ),
      ],
    );
  }

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
            buildPaginatedTable(),
          ],
        ),
      ),
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
          icon: Icon(Icons.arrow_back),
          onPressed:
              currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
        ),
        Text('Page ${currentPage + 1} of $totalPages'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: currentPage < totalPages - 1
              ? () => onPageChanged(currentPage + 1)
              : null,
        ),
      ],
    );
  }
}
