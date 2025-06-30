import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:admin/screens/main/components/side_menu.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart'; // Tambahkan ini
import '../../models/sensor_reading.dart'; // Tambahkan ini
import '../dashboard/components/header.dart';

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
  DateTime? selectedDateTime;
  String selectedModule = 'All';
  final List<String> modules = ['All', 'Module 1', 'Module 2', 'Module 3'];

  // Tambahkan list untuk menyimpan data dari firebase
  Map<String, List<SensorReading>> allModuleReadings = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['module'] != null) {
      selectedModule = args['module'];
      _filterByModule(selectedModule);
    }
  }

  Future<void> _fetchAllData() async {
    setState(() => isLoading = true);
    FirebaseService().getAllModulesData().first.then((data) {
      setState(() {
        allModuleReadings = data;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = !Responsive.isDesktop(context);

    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: isMobile ? const SideMenu() : null,
      backgroundColor: kCardBackground,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile) const Expanded(flex: 1, child: SideMenu()),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 32, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Header(title: "Log History"),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFilters(context),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: const Text("Lihat Date/Time"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                _showDateTimeDialog(
                                    context, _getAllDateTimes());
                              },
                            ),
                            if (selectedDateTime != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      "Filter: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime!)}",
                                      style: const TextStyle(
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          selectedDateTime = null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 16),
                            isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : _buildResponsiveTable(context),
                          ],
                        ),
                      ),
                    ),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          icon: const Icon(Icons.arrow_drop_down_rounded,
              color: kPrimaryColor, size: 30),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: modules.map((module) {
            return DropdownMenuItem<String>(
              value: module,
              child: Row(
                children: [
                  const Icon(Icons.developer_board,
                      size: 20, color: kAccentColor),
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
    final rows = _getFilteredRows();

    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text("No data found",
                  style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(kCardBackground),
              dataRowColor: MaterialStateProperty.all(Colors.white),
              columnSpacing: 24,
              dividerThickness: 0.5,
              columns: const [
                DataColumn(
                  label: Text(
                    "🧩 Module",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "🌡️ Temp",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "💧 Moisture",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
              ],
              rows: rows,
            ),
          ),
        );
      },
    );
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
    // Ambil data dari allModuleReadings
    final List<String> filteredModules = selectedModule == 'All'
        ? ['module1', 'module2', 'module3']
        : [selectedModule.toLowerCase().replaceAll(' ', '')];

    for (final module in filteredModules) {
      final readings = allModuleReadings[module] ?? [];
      for (final reading in readings) {
        final dateOnly = DateTime(reading.timestamp.year,
            reading.timestamp.month, reading.timestamp.day);
        final startDateOnly = startDate != null
            ? DateTime(startDate!.year, startDate!.month, startDate!.day)
            : null;
        final endDateOnly = endDate != null
            ? DateTime(endDate!.year, endDate!.month, endDate!.day)
            : null;

        if (selectedDateTime != null &&
            DateFormat('yyyy-MM-dd HH:mm').format(reading.timestamp) !=
                DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime!)) {
          continue;
        }
        if (startDateOnly != null && dateOnly.isBefore(startDateOnly)) continue;
        if (endDateOnly != null && dateOnly.isAfter(endDateOnly)) continue;

        rows.add(DataRow(
          cells: [
            DataCell(
              Row(
                children: [
                  const Icon(Icons.memory, color: Colors.blueGrey, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    module[0].toUpperCase() +
                        module.substring(1), // Module1, Module2, dst
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            DataCell(Row(
              children: [
                const Icon(Icons.thermostat, color: Colors.orange, size: 18),
                const SizedBox(width: 6),
                Text(
                  "${reading.temperature}°C",
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
                  "${reading.humidity}%",
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
    }
    return rows;
  }

  void _showDateTimeDialog(BuildContext context, List<DateTime> dateList) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daftar Date/Time'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: dateList.length,
            itemBuilder: (context, i) => ListTile(
              leading: const Icon(Icons.calendar_today, color: kPrimaryColor),
              title: Text(DateFormat('yyyy-MM-dd HH:mm').format(dateList[i])),
              onTap: () {
                setState(() {
                  selectedDateTime = dateList[i];
                });
                Navigator.pop(context);
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  List<DateTime> _getAllDateTimes() {
    // Gabungkan semua timestamp dari allModuleReadings
    final List<DateTime> allDates = [];
    allModuleReadings.forEach((_, readings) {
      allDates.addAll(readings.map((e) => e.timestamp));
    });
    allDates.sort((a, b) => b.compareTo(a));
    return allDates;
  }

  void _filterByModule(String module) {
    setState(() {
      selectedModule = module;
    });
  }
}
