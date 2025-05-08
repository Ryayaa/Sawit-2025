import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Add this import
import '../../constants.dart';
import '../../controllers/menu_app_controller.dart';
import '../../responsive.dart';
import '../main/components/side_menu.dart';
import '../dashboard/components/header.dart';

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
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                flex: 1,
                child: SideMenu(),
              ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                primary: false,
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  children: [
                    const Header(title: "Log History"),
                    const SizedBox(height: defaultPadding),
                    Container(
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Responsive filter controls
                          if (Responsive.isMobile(context))
                            _buildMobileFilters()
                          else
                            _buildDesktopFilters(),
                          const SizedBox(height: defaultPadding),
                          // Responsive table
                          _buildResponsiveTable(),
                        ],
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

  Widget _buildMobileFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Date Range"),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: Text(startDate == null
              ? "Start Date"
              : DateFormat('yyyy-MM-dd').format(startDate!)),
          onPressed: () => _selectDate(true),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: Text(endDate == null
              ? "End Date"
              : DateFormat('yyyy-MM-dd').format(endDate!)),
          onPressed: () => _selectDate(false),
        ),
        const SizedBox(height: 16),
        const Text("Module"),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
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

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Date Range"),
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
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Module"),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
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
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveTable() {
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Column(
        children: _getFilteredRows().map((row) {
          final cells = row.cells;
          final dateTime = (cells[0].child as Text).data!;
          final date = dateTime.split(' ')[0]; // Get date part
          final time = dateTime.split(' ')[1]; // Get time part

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _getModuleColor((cells[1].child as Text).data!),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (cells[1].child as Text).data!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            date, // Show date
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            time, // Show time
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.thermostat,
                          color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Suhu: ${(cells[2].child as Text).data}",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.water_drop,
                          color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Kelembapan: ${(cells[3].child as Text).data}",
                        style: const TextStyle(
                          color: Colors.white,
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
      return DataTable(
        columns: const [
          DataColumn(label: Text("Date/Time")),
          DataColumn(label: Text("Module")),
          DataColumn(label: Text("Temperature")),
          DataColumn(label: Text("Soil Moisture")),
        ],
        rows: _getFilteredRows(),
      );
    }
  }

  Color _getModuleColor(String moduleName) {
    switch (moduleName) {
      case 'Module 1':
        return const Color(0xFF8B4513); // Brown/Maroon color
      case 'Module 2':
        return const Color(0xFF1E4478); // Dark blue color
      case 'Module 3':
        return const Color(0xFF2F4F4F); // Dark green color
      default:
        return Colors.blueGrey;
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
    return List.generate(
      15,
      (index) {
        final date = DateTime.now().subtract(Duration(minutes: index * 5));
        final moduleNum = (index % 3) + 1;

        // Fix date comparison by converting to date only (removing time)
        final dateOnly = DateTime(date.year, date.month, date.day);
        final startDateOnly = startDate != null
            ? DateTime(startDate!.year, startDate!.month, startDate!.day)
            : null;
        final endDateOnly = endDate != null
            ? DateTime(endDate!.year, endDate!.month, endDate!.day)
            : null;

        // Apply filters with corrected date comparison
        if (startDateOnly != null && dateOnly.isBefore(startDateOnly))
          return null;
        if (endDateOnly != null && dateOnly.isAfter(endDateOnly)) return null;
        if (selectedModule != 'All' && 'Module $moduleNum' != selectedModule)
          return null;

        return DataRow(
          cells: [
            DataCell(Text(DateFormat('yyyy-MM-dd HH:mm')
                .format(date))), // Format date nicely
            DataCell(Text("Module $moduleNum")),
            DataCell(Text("${28 + (index % 3)}°C")),
            DataCell(Text("${60 + (index % 3)}%")),
          ],
        );
      },
    ).where((row) => row != null).cast<DataRow>().toList();
  }
}
