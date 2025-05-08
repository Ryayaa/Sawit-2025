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
                          // Filter controls
                          Row(
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
                                            icon: const Icon(
                                                Icons.calendar_today),
                                            label: Text(startDate == null
                                                ? "Start Date"
                                                : DateFormat('yyyy-MM-dd')
                                                    .format(startDate!)),
                                            onPressed: () async {
                                              final date = await showDatePicker(
                                                context: context,
                                                initialDate:
                                                    startDate ?? DateTime.now(),
                                                firstDate: DateTime(2020),
                                                lastDate: DateTime.now(),
                                              );
                                              if (date != null) {
                                                setState(
                                                    () => startDate = date);
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            icon: const Icon(
                                                Icons.calendar_today),
                                            label: Text(endDate == null
                                                ? "End Date"
                                                : DateFormat('yyyy-MM-dd')
                                                    .format(endDate!)),
                                            onPressed: () async {
                                              final date = await showDatePicker(
                                                context: context,
                                                initialDate:
                                                    endDate ?? DateTime.now(),
                                                firstDate: DateTime(2020),
                                                lastDate: DateTime.now(),
                                              );
                                              if (date != null) {
                                                setState(() => endDate = date);
                                              }
                                            },
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
                          ),
                          const SizedBox(height: defaultPadding),
                          // Data table
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text("Date/Time")),
                                DataColumn(label: Text("Module")),
                                DataColumn(label: Text("Temperature")),
                                DataColumn(label: Text("Soil Moisture")),
                              ],
                              rows: _getFilteredRows(),
                            ),
                          ),
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

  List<DataRow> _getFilteredRows() {
    return List.generate(
      15,
      (index) {
        final date = DateTime.now().subtract(Duration(minutes: index * 5));
        final moduleNum = (index % 3) + 1;

        // Apply filters
        if (startDate != null && date.isBefore(startDate!)) return null;
        if (endDate != null && date.isAfter(endDate!)) return null;
        if (selectedModule != 'All' && 'Module $moduleNum' != selectedModule)
          return null;

        return DataRow(
          cells: [
            DataCell(Text(date.toString().substring(0, 16))),
            DataCell(Text("Module $moduleNum")),
            DataCell(Text("${28 + (index % 3)}°C")),
            DataCell(Text("${60 + (index % 3)}%")),
          ],
        );
      },
    ).where((row) => row != null).cast<DataRow>().toList();
  }
}
