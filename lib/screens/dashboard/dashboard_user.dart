import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../main/components/side_menu_user.dart';
import '../../controllers/menu_app_controller.dart';
import '../../constants.dart';
import '../../responsive.dart';
import '../../services/firebase_service.dart';
import '../../models/sensor_reading.dart';
import 'components/header_user.dart';
import 'components/live_chart.dart';
import 'components/cuaca_besok_widget.dart';
import 'components/recent_measurements_table.dart';
import '../../services/auth_service.dart';

class DashboardUser extends StatefulWidget {
  const DashboardUser({super.key});

  @override
  State<DashboardUser> createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser> {
  final FirebaseService _firebaseService = FirebaseService();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: const SideMenuUser(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show side menu only on desktop mode
            if (Responsive.isDesktop(context))
              const Expanded(
                flex: 1,
                child: SideMenuUser(),
              ),
            // Main content
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                primary: false,
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  children: [
                    const HeaderUser(), // Will use default "Dashboard" title
                    const SizedBox(height: defaultPadding),

                    // Add this after HeaderUser
                    StreamBuilder<Map<String, dynamic>>(
                      stream: AuthService().getUserData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        // Get data from snapshot and handle null cases
                        final userData =
                            snapshot.data ?? {'name': 'User', 'role': 2};
                        final isAdmin = userData['role'] == 1;
                        final userName = userData['name'] ?? 'User';
                        final roleText = isAdmin ? 'Admin' : 'User';

                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, top: 16.0, bottom: 4.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Selamat datang, $userName ($roleText) 👋",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[900],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: defaultPadding),

                    // Widget cuaca dan suhu
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: DefaultTextStyle(
                        style: TextStyle(color: Colors.black),
                        child: CuacaBesokWidget(),
                      ),
                    ),
                    const SizedBox(height: defaultPadding),

                    // Modul 1
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        color: const Color(0xFFF5F6FA),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: LiveChart(
                            moduleName: 'Modul 1',
                            dataStream:
                                _firebaseService.getModuleData('module1'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: defaultPadding),

                    // Modul 2
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        color: const Color(0xFFF5F6FA),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: LiveChart(
                            moduleName: 'Modul 2',
                            dataStream:
                                _firebaseService.getModuleData('module2'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: defaultPadding),

                    // Modul 3
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        color: const Color(0xFFF5F6FA),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: LiveChart(
                            moduleName: 'Modul 3',
                            dataStream:
                                _firebaseService.getModuleData('module3'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: defaultPadding),

                    // Tabel data terbaru
                    StreamBuilder<Map<String, List<SensorReading>>>(
                      stream: _firebaseService.getAllModulesData(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final allData = snapshot.data!;
                        final measurements = allData.entries.map((e) {
                          final lastReading = e.value.last;
                          return {
                            'module': int.parse(e.key.replaceAll('module', '')),
                            'temperature': lastReading.temperature,
                            'soilMoisture': lastReading.soilMoisture,
                          };
                        }).toList();

                        return RecentMeasurementsTable(
                          initialMeasurements: measurements,
                        );
                      },
                    ),
                    const SizedBox(height: defaultPadding),

                    // GPS placeholder
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "GPS Map View Here",
                          style: TextStyle(color: Colors.white70),
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
}
