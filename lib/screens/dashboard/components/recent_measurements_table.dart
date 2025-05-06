import 'dart:async';

import 'package:flutter/material.dart';

class RecentMeasurementsTable extends StatefulWidget {
  final List<Map<String, dynamic>> initialMeasurements;

  const RecentMeasurementsTable({Key? key, required this.initialMeasurements})
      : super(key: key);

  @override
  _RecentMeasurementsTableState createState() =>
      _RecentMeasurementsTableState();
}

class _RecentMeasurementsTableState extends State<RecentMeasurementsTable> {
  late List<Map<String, dynamic>> measurements;

  @override
  void initState() {
    super.initState();
    measurements = widget.initialMeasurements;
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    Timer.periodic(const Duration(minutes: 5), (timer) {
      setState(() {
        measurements = measurements.map((data) {
          return {
            'module': data['module'],
            'temperature': (data['temperature'] + 1) % 35, // Dummy update
            'soilMoisture': (data['soilMoisture'] + 1) % 80, // Dummy update
          };
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Measurements",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth, // Lebar minimal mengikuti layar
                  ),
                  child: Table(
                    columnWidths: {
                      0: FlexColumnWidth(1.5), // Kolom 1 lebih kecil
                      1: FlexColumnWidth(2.5), // Kolom 2 lebih besar
                      2: FlexColumnWidth(2.5), // Kolom 3 lebih besar
                    },
                    border: TableBorder.all(color: Colors.white24),
                    children: [
                      _buildTableHeader(),
                      ...measurements.map((data) => _buildTableRow(data)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFF1D1D35)),
      children: [
        _buildTableHeaderCell("Module"),
        _buildTableHeaderCell("Temperature"),
        _buildTableHeaderCell("Soil Moisture"),
      ],
    );
  }

  TableRow _buildTableRow(Map<String, dynamic> data) {
    return TableRow(
      children: [
        _buildTableCell(data['module'].toString()),
        _buildTableCell("${data['temperature']}°C"),
        _buildTableCell("${data['soilMoisture']}%"),
      ],
    );
  }

  Widget _buildTableHeaderCell(String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 14, // Ukuran font yang konsisten
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis, // Hindari teks turun ke bawah
      ),
    );
  }

  Widget _buildTableCell(String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14, // Ukuran font yang konsisten
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis, // Hindari teks turun ke bawah
      ),
    );
  }
}
