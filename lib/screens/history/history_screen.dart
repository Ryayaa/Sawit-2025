import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:admin/screens/main/components/side_menu.dart'; // sudah ada

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
      drawer: const SideMenu(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true, // tombol menu otomatis muncul
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
          // Ambil Text dari Row pada DataCell
          final cells = row.cells;
          final dateRow = cells[0].child as Row;
          final dateText = dateRow.children.whereType<Text>().first.data!;
          final date = dateText.split(' ')[0];
          final time = dateText.split(' ')[1];

          final moduleRow = cells[1].child as Row;
          final moduleText = moduleRow.children.whereType<Text>().first.data!;

          final suhuRow = cells[2].child as Row;
          final suhuText = suhuRow.children.whereType<Text>().first.data!;

          final kelembapanRow = cells[3].child as Row;
          final kelembapanText = kelembapanRow.children.whereType<Text>().first.data!;

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
                            moduleText,
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
                        "Suhu: $suhuText",
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
                        "Kelembapan: $kelembapanText",
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
            DataColumn(
              label: Text(
                "Date/Time",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A7D44), // hijau tua, kontras dengan putih
                ),
              ),
            ),
            DataColumn(
              label: Text(
                "Module",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A7D44),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                "Temperature",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A7D44),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                "Soil Moisture",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A7D44),
                ),
              ),
            ),
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
          DataCell(Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFF3A7D44), size: 18),
              const SizedBox(width: 6),
              Text(
                DateFormat('yyyy-MM-dd HH:mm').format(date),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
            ],
          )),
          DataCell(Row(
            children: [
              const Icon(Icons.memory, color: Colors.blueGrey, size: 18),
              const SizedBox(width: 6),
              Text(
                "Module $moduleNum",
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
            ],
          )),
          DataCell(Row(
            children: [
              const Icon(Icons.thermostat, color: Colors.orange, size: 18),
              const SizedBox(width: 6),
              Text(
                "${28 + (index % 3)}°C",
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
            ],
          )),
          DataCell(Row(
            children: [
              const Icon(Icons.water_drop, color: Colors.blue, size: 18),
              const SizedBox(width: 6),
              Text(
                "${60 + (index % 3)}%",
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
            ],
          )),
        ],
      ));
    }
    return rows;
  }
}
