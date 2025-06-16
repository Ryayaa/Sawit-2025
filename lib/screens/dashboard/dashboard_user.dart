import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main/components/side_menu_user.dart';
import '../../controllers/menu_app_controller.dart';
import '../../constants.dart';
import '../../responsive.dart';
import 'components/header_user.dart';
import 'components/live_chart.dart';
import 'components/cuaca_besok_widget.dart';
import 'components/recent_measurements_table.dart';
import '../../services/firebase_service.dart';
import '../../models/sensor_reading.dart';
import '../../services/auth_service.dart';
import '../../models/gps_coordinate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

const kPrimaryColor = Color(0xFF3A7D44);
const kAccentColor = Color(0xFF91C788);
const kCardBackground = Color(0xFFF9F9F9);
const kShadowColor = Color(0xFFE0E0E0);

class DashboardUser extends StatelessWidget {
  const DashboardUser({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MenuAppController(),
          lazy: true,
        ),
      ],
      child: const DashboardUserView(),
    );
  }
}

class DashboardUserView extends StatefulWidget {
  const DashboardUserView({super.key});

  @override
  State<DashboardUserView> createState() => _DashboardUserViewState();
}

class _DashboardUserViewState extends State<DashboardUserView> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: const SideMenuUser(),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (Responsive.isDesktop(context))
                const Expanded(
                  flex: 1,
                  child: SideMenuUser(),
                ),
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  primary: false,
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    children: [
                      // Header
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: DefaultTextStyle(
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                          child: HeaderUser(),
                        ),
                      ),
                      const SizedBox(height: defaultPadding),

                      // Salam selamat datang user
                      StreamBuilder<Map<String, dynamic>>(
                        stream: AuthService().getUserData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          final userData = snapshot.data ?? {'name': 'User', 'role': 2};
                          final userName = userData['name'] ?? 'User';
                          final roleText = userData['role'] == 1 ? 'Admin' : 'User';

                          return Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 4.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Selamat datang, $userName ($roleText) 👋",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: defaultPadding),

                      // Widget cuaca
                      Card(
                        color: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        shadowColor: kShadowColor,
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: DefaultTextStyle(
                            style: TextStyle(color: Colors.black),
                            child: CuacaBesokWidget(),
                          ),
                        ),
                      ),
                      const SizedBox(height: defaultPadding),

                      // Statistik Ringkas
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                child: _buildStatCard("Modul Aktif", "3",
                                    Icons.memory, Colors.green)),
                            Expanded(
                                child: _buildStatCard(
                                    "Suhu Rata-rata",
                                    "29°C",
                                    Icons.thermostat,
                                    Colors.orange)),
                            Expanded(
                                child: _buildStatCard("Kelembapan", "65%",
                                    Icons.water_drop, Colors.blue)),
                          ],
                        ),
                      ),
                      const SizedBox(height: defaultPadding),

                      // Target Kelembapan
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Target Kelembapan",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[800]),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: 0.71,
                              minHeight: 10,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "71% tercapai dari target 100%",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
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
                      Card(
                        color: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        shadowColor: kShadowColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: StreamBuilder<Map<String, List<SensorReading>>>(
                            stream: _firebaseService.getAllModulesData(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              if (!snapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
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
                        ),
                      ),
                      const SizedBox(height: defaultPadding),

                      // GPS placeholder
                      Card(
                        color: kPrimaryColor,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: const Center(
                            child: Text(
                              "GPS Map View Here",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: defaultPadding),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          "© 2025 I-SAWIT | All rights reserved",
                          style: TextStyle(
                              color: Colors.black38, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        "Hubungi: admin@sawit.com | v1.0.0",
                        style:
                            TextStyle(color: Colors.black26, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
