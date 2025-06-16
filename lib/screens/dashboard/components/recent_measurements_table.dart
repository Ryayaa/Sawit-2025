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
  late List<Map<String, dynamic>> _measurements;

  @override
  void initState() {
    super.initState();
    _measurements = widget.initialMeasurements;
  }

  @override
  void didUpdateWidget(covariant RecentMeasurementsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMeasurements != oldWidget.initialMeasurements) {
      setState(() {
        _measurements = widget.initialMeasurements;
      });
    }
  }

  Widget buildPaginatedTable() {
    final int totalPages = (_measurements.length / itemsPerPage).ceil();
    final int startIndex = _currentPage * itemsPerPage;
    final int endIndex = (startIndex + itemsPerPage > _measurements.length)
        ? _measurements.length
        : startIndex + itemsPerPage;

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 28,
            headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
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
                                size: 18, color: Colors.green.shade700),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                data['module'].toString(),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          "${data['temperature']}°",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          "${data['soilMoisture']}%",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blueAccent,
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
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Data Terbaru",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
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
