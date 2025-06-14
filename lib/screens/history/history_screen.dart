import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:admin/screens/main/components/side_menu.dart';

const kPrimaryColor = Color(0xFF3A7D44);
const kAccentColor = Color(0xFF91C788);
const kCardBackground = Color(0xFFF9F9F9);
const kShadowColor = Color(0xFFE0E0E0);

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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: kShadowColor,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: kPrimaryColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Log History",
          style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: const SideMenu(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 32, vertical: 16),
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
                    _buildFilters(context),
                    const SizedBox(height: 16),
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
                  backgroundColor: kCardBackground,
                  foregroundColor: kPrimaryColor,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  backgroundColor: kCardBackground,
                  foregroundColor: kPrimaryColor,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text("Module", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
  value: selectedModule,
  onChanged: (value) => setState(() => selectedModule = value!),
  decoration: InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF0F4F8),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    prefixIcon: const Icon(Icons.memory, color: kPrimaryColor),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: kPrimaryColor, width: 2),
    ),
    labelText: "Pilih Modul",
    labelStyle: const TextStyle(color: kPrimaryColor),
  ),
  icon: const Icon(Icons.arrow_drop_down_rounded, color: kPrimaryColor, size: 30),
  dropdownColor: Colors.white,
  borderRadius: BorderRadius.circular(12),
  items: modules.map((module) {
    return DropdownMenuItem<String>(
      value: module,
      child: Row(
        children: [
          const Icon(Icons.developer_board, size: 20, color: kAccentColor),
          const SizedBox(width: 8),
          Text(
            module,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }).toList(),
),

      ],
    );
  }

  Widget _buildResponsiveTable(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final rows = _getFilteredRows();

    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text("No data found", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            ],
          ),
        ),
      );
    }

    if (isMobile) {
      return Column(
        children: rows.map((row) {
          final cells = row.cells;
          final dateTime = (cells[0].child as Text).data!;
          final date = dateTime.split(' ')[0];
          final time = dateTime.split(' ')[1];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: kCardBackground,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: kShadowColor,
                  offset: const Offset(0, 3),
                  blurRadius: 6,
                )
              ],
            ),
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
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(date, style: const TextStyle(fontSize: 15, color: Color.fromARGB(137, 0, 0, 0), fontWeight: FontWeight.bold)),
                        Text(time, style: const TextStyle(fontSize: 13, color: Colors.black54)),
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
                    color: Colors.black87, // << INI warna tulisan suhu
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
                      color: Colors.black87, // << INI warna tulisan kelembapan
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(kCardBackground),
          dataRowColor: MaterialStateProperty.all(Colors.white),
          columnSpacing: 24,
          dividerThickness: 0.5,
          columns: const [
            DataColumn(label: Text("📅 Date/Time")),
            DataColumn(label: Text("🧩 Module")),
            DataColumn(label: Text("🌡️ Temp")),
            DataColumn(label: Text("💧 Moisture")),
          ],
          rows: rows,
        ),
      );
    }
  }

  Future<void> _selectDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now()),
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
      final startDateOnly = startDate != null ? DateTime(startDate!.year, startDate!.month, startDate!.day) : null;
      final endDateOnly = endDate != null ? DateTime(endDate!.year, endDate!.month, endDate!.day) : null;

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
