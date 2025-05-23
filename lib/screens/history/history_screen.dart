import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? startDate;
  DateTime? endDate;
  String selectedModule = 'All';
  final List<String> modules = ['All', 'Module 1', 'Module 2', 'Module 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF3A7D44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Log History",
          style: TextStyle(color: Color(0xFF3A7D44), fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter
                    _buildFilters(context),
                    const SizedBox(height: 16),
                    // Table
                    _buildResponsiveTable(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Date Range", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(startDate == null
                    ? "Start Date"
                    : DateFormat('yyyy-MM-dd').format(startDate!)),
                onPressed: () => _selectDate(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(endDate == null
                    ? "End Date"
                    : DateFormat('yyyy-MM-dd').format(endDate!)),
                onPressed: () => _selectDate(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text("Module", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
          value: selectedModule,
          items: modules
              .map((module) => DropdownMenuItem(
                    value: module,
                    child: Text(module),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() => selectedModule = value!);
          },
        ),
      ],
    );
  }

  Widget _buildResponsiveTable(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final rows = _getFilteredRows();

    if (isMobile) {
      return Column(
        children: rows.map((row) {
          final cells = row.cells;
          final dateTime = (cells[0].child as Text).data!;
          final date = dateTime.split(' ')[0];
          final time = dateTime.split(' ')[1];

          return Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.memory, color: Colors.blueGrey[400], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            (cells[1].child as Text).data!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3A7D44),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.thermostat, color: Colors.orange[400], size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Suhu: ${(cells[2].child as Text).data}",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.water_drop, color: Colors.blue[400], size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Kelembapan: ${(cells[3].child as Text).data}",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFFF5F6FA)),
          columns: const [
            DataColumn(label: Text("Date/Time", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Module", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Temperature", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Soil Moisture", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: rows,
        ),
      );
    }
  }

  Future<void> _selectDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (startDate ?? DateTime.now())
          : (endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        if (isStartDate) {
          startDate = date;
        } else {
          endDate = date;
        }
      });
    }
  }

  List<DataRow> _getFilteredRows() {
    final List<DataRow> rows = [];
    for (int index = 0; index < 15; index++) {
      final date = DateTime.now().subtract(Duration(minutes: index * 5));
      final moduleNum = (index % 3) + 1;
      final dateOnly = DateTime(date.year, date.month, date.day);
      final startDateOnly = startDate != null
          ? DateTime(startDate!.year, startDate!.month, startDate!.day)
          : null;
      final endDateOnly = endDate != null
          ? DateTime(endDate!.year, endDate!.month, endDate!.day)
          : null;
      if (startDateOnly != null && dateOnly.isBefore(startDateOnly)) continue;
      if (endDateOnly != null && dateOnly.isAfter(endDateOnly)) continue;
      if (selectedModule != 'All' && 'Module $moduleNum' != selectedModule) continue;
      rows.add(DataRow(
        cells: [
          DataCell(Text(DateFormat('yyyy-MM-dd HH:mm').format(date))),
          DataCell(Text("Module $moduleNum")),
          DataCell(Text("${28 + (index % 3)}°C")),
          DataCell(Text("${60 + (index % 3)}%")),
        ],
      ));
    }
    return rows;
  }
}
