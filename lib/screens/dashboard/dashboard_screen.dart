import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main/components/side_menu.dart';
import '../../controllers/menu_app_controller.dart';
import '../../controllers/dashboard_controller.dart'; // Tambahkan import ini
import '../../constants.dart';
import '../../responsive.dart';
import 'components/header.dart';
import 'components/live_chart.dart';
import 'components/cuaca_besok_widget.dart';
import 'components/recent_measurements_table.dart';
import '../../services/firebase_service.dart';
import '../../models/sensor_reading.dart';
import '../../services/notification_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../models/gps_coordinate.dart';
import 'dart:async';
import '../../services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MenuAppController(), // Perbaikan provider
          lazy: true,
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardController(),
          lazy: true,
        ),
      ],
      child: const DashboardView(), // Tambahkan const
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final FirebaseService _firebaseService = FirebaseService();
  List<StreamSubscription<List<SensorReading>>>? _subscriptions;
  final Map<String, bool> _moduleAlerts = {
    'module1': false,
    'module2': false,
    'module3': false,
  };

  late Future<void> _initialization;
  final ScrollController? _scrollController = ScrollController();

  void _setupModuleListeners() {
    try {
      _subscriptions = ['module1'].map((moduleId) {
        // Start with only one module
        return _firebaseService.getModuleData(moduleId).listen(
              (data) => _checkTemperature(moduleId, data),
              onError: (error) => print('Error listening to $moduleId: $error'),
            );
      }).toList();

      // Load other modules after delay
      Future.delayed(const Duration(seconds: 2), () {
        _addRemainingModuleListeners();
      });
    } catch (e) {
      print('Error in setup listeners: $e');
    }
  }

  void _addRemainingModuleListeners() {
    try {
      final remainingModules = ['module2', 'module3'];
      for (var moduleId in remainingModules) {
        final subscription = _firebaseService.getModuleData(moduleId).listen(
              (data) => _checkTemperature(moduleId, data),
              onError: (error) => print('Error listening to $moduleId: $error'),
            );
        _subscriptions?.add(subscription);
      }
    } catch (e) {
      print('Error adding remaining listeners: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    NotificationService.initialize();
    _initialization = _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Load critical data first
      await Future.wait([
        NotificationService.initialize(),
        _loadCriticalData(),
      ]);

      // Load non-critical data after UI is shown
      Future.delayed(const Duration(milliseconds: 100), () {
        _loadNonCriticalData();
      });
    } catch (e) {
      print('Error initializing data: $e');
      // Handle initialization error
    }
  }

  Future<void> _loadCriticalData() async {
    // Load only essential data for initial render
    try {
      _setupModuleListeners();
    } catch (e) {
      print('Error loading critical data: $e');
    }
  }

  Future<void> _loadNonCriticalData() async {
    // Implementasi pemuatan data non-kritis (jika ada)
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _subscriptions?.forEach((sub) => sub.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: const SideMenu(),
      body: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          return Container(
            color: Colors.white, // Background putih polos
            child: SafeArea(
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
                          // Header
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: DefaultTextStyle(
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold),
                              child: Header(),
                            ),
                          ),
                          SizedBox(height: defaultPadding),

                          // Salam selamat datang
                          StreamBuilder<String>(
                            stream: AuthService().getUserDisplayName(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, top: 16.0, bottom: 4.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Selamat datang, ${snapshot.data ?? 'User'} 👋",
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

                          // Peringatan suhu (letakkan di sini, paling atas)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.orange, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning,
                                      color: Colors.orange[800]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Peringatan: Suhu modul 2 di atas normal!",
                                      style: TextStyle(
                                        color: Colors.orange[900],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: defaultPadding),

                          // Widget cuaca tanpa Card
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CuacaBesokWidget(),
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
                                  value: 0.71, // misal 71% dari target
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

                          // Modul 1 dengan Card hijau
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

                          // Modul 2 dengan Card hijau
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Card(
                              color: const Color(
                                  0xFFF5F6FA), // abu-abu muda, sangat soft
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

                          // Modul 3 dengan Card hijau
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Card(
                              color: const Color(
                                  0xFFF5F6FA), // abu-abu muda, sangat soft
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

                          // Tabel data terbaru tanpa Card
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: DefaultTextStyle(
                              style: const TextStyle(color: Colors.black),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _refreshData,
                                        icon:
                                            const Icon(Icons.refresh, size: 18),
                                        label: const Text("Refresh Data"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[700],
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  RecentMeasurementsTable(
                                    initialMeasurements: [
                                      {
                                        'module': 1,
                                        'temperature': 30,
                                        'soilMoisture': 68
                                      },
                                      {
                                        'module': 2,
                                        'temperature': 29,
                                        'soilMoisture': 71
                                      },
                                      {
                                        'module': 3,
                                        'temperature': 28,
                                        'soilMoisture': 69
                                      },
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: defaultPadding),

                          // GPS placeholder tanpa Card
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: StreamBuilder<GPSCoordinate>(
                              stream: _firebaseService.getModule1Location(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.error_outline,
                                              color: Colors.red, size: 48),
                                          const SizedBox(height: 16),
                                          Text(
                                              'Error loading GPS data: ${snapshot.error}'),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                // Tambahkan pengecekan data kosong
                                if (!snapshot.hasData ||
                                    (snapshot.data?.latitude == 0 &&
                                        snapshot.data?.longitude == 0)) {
                                  return const Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                        child: Text('No GPS data available'),
                                      ),
                                    ),
                                  );
                                }

                                final location = snapshot.data!;
                                final point = LatLng(
                                    location.latitude, location.longitude);

                                return Container(
                                  height: 300,
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Lokasi Modul 1',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[900],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: Card(
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: FlutterMap(
                                              options: MapOptions(
                                                center: point,
                                                zoom: 15,
                                                // Add these options for interactivity
                                                minZoom:
                                                    3, // Minimum zoom level
                                                maxZoom:
                                                    18, // Maximum zoom level
                                                enableScrollWheel: true,
                                                interactionOptions:
                                                    const InteractionOptions(
                                                  enableMultiFingerGestureRace:
                                                      true,
                                                  flags: InteractiveFlag.all,
                                                ),
                                              ),
                                              children: [
                                                TileLayer(
                                                  urlTemplate:
                                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                  userAgentPackageName:
                                                      'com.example.sawit',
                                                ),
                                                MarkerLayer(
                                                  markers: [
                                                    Marker(
                                                      point: point,
                                                      child: const Icon(
                                                        Icons.location_on,
                                                        color:
                                                            Color(0xFF3A7D44),
                                                        size: 40,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Last Updated: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.fromMillisecondsSinceEpoch(location.lastUpdate ?? 0))}',
                                        style: const TextStyle(
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                );
                              },
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
          );
        },
      ),
    );
  }

  Future<void> _refreshData() async {
    try {
      setState(() {
        _moduleAlerts.updateAll((key, value) => false);
      });

      // Cancel existing subscriptions
      await Future.wait(_subscriptions?.map((s) => s.cancel()) ?? []);

      // Setup new listeners
      _setupModuleListeners();
    } catch (e) {
      _showErrorDialog('Gagal memperbarui data: $e');
    }
  }

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

  void _checkTemperature(String moduleId, List<SensorReading> readings) {
    try {
      if (readings.isNotEmpty) {
        double latestTemp = readings.last.temperature;
        if (latestTemp >= 40.0) {
          NotificationService.showTemperatureAlert(moduleId, latestTemp);
          setState(() {
            _moduleAlerts[moduleId] = true;
          });
        }
      }
    } catch (e) {
      print('Error in _checkTemperature: $e');
      _showErrorDialog('Error saat memeriksa suhu: $e');
    }
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
