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
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'components/gps_widget.dart'; // Tambahkan import ini

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
  final ScrollController _scrollController = ScrollController();
  final List<StreamSubscription<List<SensorReading>>> _subscriptions = [];
  final Map<String, bool> _moduleAlerts = {
    'module1_temp': false,
    'module1_humidity': false,
    'module2_temp': false,
    'module2_humidity': false,
    'module3_temp': false,
    'module3_humidity': false,
  };

  double _tempMinNormal = 25.0;
  double _tempMaxNormal = 35.0;
  double _humidityMinNormal = 60.0;
  double _humidityMaxNormal = 80.0;
  double _tempThreshold = 40.0;
  double _humidityThreshold = 30.0;

  final Map<String, List<SensorReading>> _moduleReadings = {
    'module1': [],
    'module2': [],
    'module3': [],
  };

  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initializeData();
  }

  Future<void> _initializeData() async {
    _setupModuleListeners();
    _listenRangeSettings();
  }

  void _setupModuleListeners() {
    try {
      for (final moduleId in ['module1', 'module2', 'module3']) {
        final subscription = _firebaseService.getModuleData(moduleId).listen(
              (data) => _checkTemperature(moduleId, data),
              onError: (error) => print('Error listening to $moduleId: $error'),
            );
        _subscriptions.add(subscription);
      }
    } catch (e) {
      print('Error in setup listeners: $e');
    }
  }

  void _listenRangeSettings() {
    final dbRef = FirebaseDatabase.instance.ref();
    dbRef.child('notification_settings').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          _tempMinNormal = (data['tempMinNormal'] ?? 25).toDouble();
          _tempMaxNormal = (data['tempMaxNormal'] ?? 35).toDouble();
          _humidityMinNormal = (data['humidityMinNormal'] ?? 60).toDouble();
          _humidityMaxNormal = (data['humidityMaxNormal'] ?? 80).toDouble();
          _tempThreshold = (data['tempThreshold'] ?? 40).toDouble();
          _humidityThreshold = (data['humidityThreshold'] ?? 30).toDouble();

          // Cek ulang alert setelah threshold berubah
          for (final moduleId in ['module1', 'module2', 'module3']) {
            final readings = _moduleReadings[moduleId];
            if (readings != null && readings.isNotEmpty) {
              final latest = readings.last;
              _moduleAlerts['${moduleId}_temp'] =
                  latest.temperature >= _tempThreshold;
              _moduleAlerts['${moduleId}_humidity'] =
                  latest.humidity >= _humidityThreshold;
            } else {
              _moduleAlerts['${moduleId}_temp'] = false;
              _moduleAlerts['${moduleId}_humidity'] = false;
            }
          }
        });
      }
    });
  }

  // Fungsi status untuk statistik ringkas
  Map<String, bool> _checkModuleStatus(String moduleId) {
    final readings = _moduleReadings[moduleId];
    if (readings == null || readings.isEmpty) {
      return {
        'tempNormal': true,
        'humidityNormal': true,
      };
    }
    final latest = readings.last;
    return {
      'tempNormal': latest.temperature >= _tempMinNormal &&
          latest.temperature <= _tempMaxNormal,
      'humidityNormal': latest.humidity >= _humidityMinNormal &&
          latest.humidity <= _humidityMaxNormal,
    };
  }

  // Cek dan update status alert setiap data sensor baru masuk
  void _checkTemperature(String moduleId, List<SensorReading> readings) {
    if (readings.isNotEmpty) {
      final latest = readings.last;
      setState(() {
        _moduleReadings[moduleId] = readings;
        _moduleAlerts['${moduleId}_temp'] =
            latest.temperature >= _tempThreshold;
        _moduleAlerts['${moduleId}_humidity'] =
            latest.humidity >= _humidityThreshold;
      });
    }
  }

  String _getCombinedAlertMessage(String type) {
    List<String> alertedModules = [];
    for (int i = 1; i <= 3; i++) {
      if (_moduleAlerts['module${i}_$type'] == true) {
        alertedModules.add(i.toString());
      }
    }
    if (alertedModules.isEmpty) return '';
    String modules = alertedModules.length == 3
        ? '1, 2 dan 3'
        : alertedModules.length == 2
            ? '${alertedModules[0]} dan ${alertedModules[1]}'
            : alertedModules[0];
    String alertType = type == 'temp' ? 'suhu' : 'kelembaban';
    return 'Peringatan: Modul $modules mengalami kenaikan $alertType!';
  }

  Widget _buildAlertNotification(String message, bool isVisible) {
    if (!isVisible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[100], // Sama seperti dashboard_screen.dart
          border: Border.all(color: Colors.orange, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[800]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.orange[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    _setupModuleListeners();
    _listenRangeSettings();
    setState(() {
      _moduleAlerts.updateAll((key, value) => false);
    });
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: const SideMenuUser(),
      body: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Container(
            color: Colors.white, // Ganti kCardBackground dengan Colors.white
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
                      controller: _scrollController,
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Column(
                        children: [
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
                          const SizedBox(),
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
                          _AlertSection(
                            getCombinedAlertMessage: _getCombinedAlertMessage,
                            buildAlertNotification: _buildAlertNotification,
                          ),
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CuacaBesokWidget(),
                          ),
                          const SizedBox(height: defaultPadding),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isMobile = constraints.maxWidth < 400;
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: _buildModuleStatusCard(
                                        "Module 1",
                                        Icons.memory,
                                        Colors.green,
                                        _checkModuleStatus('module1'),
                                        isCompact: isMobile,
                                      ),
                                    ),
                                    SizedBox(width: isMobile ? 4 : 12),
                                    Flexible(
                                      child: _buildModuleStatusCard(
                                        "Module 2",
                                        Icons.memory,
                                        Colors.orange,
                                        _checkModuleStatus('module2'),
                                        isCompact: isMobile,
                                      ),
                                    ),
                                    SizedBox(width: isMobile ? 4 : 12),
                                    Flexible(
                                      child: _buildModuleStatusCard(
                                        "Module 3",
                                        Icons.memory,
                                        Colors.blue,
                                        _checkModuleStatus('module3'),
                                        isCompact: isMobile,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
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
                                // Progress bar langsung hitung di widget, tanpa fungsi tambahan
                                Builder(
                                  builder: (context) {
                                    List<double> humidities = [];
                                    for (var readings
                                        in _moduleReadings.values) {
                                      if (readings.isNotEmpty) {
                                        humidities.add(readings.last.humidity);
                                      }
                                    }
                                    double avgHumidity = humidities.isNotEmpty
                                        ? humidities.reduce((a, b) => a + b) /
                                            humidities.length
                                        : 0.0;
                                    double progress =
                                        (avgHumidity - _humidityMinNormal) /
                                            (_humidityMaxNormal -
                                                _humidityMinNormal);
                                    progress = progress.clamp(0.0, 1.0);

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 10,
                                          backgroundColor: Colors.grey[300],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.green),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${(progress * 100).toStringAsFixed(0)}% tercapai dari target 100%",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                          _ModuleChartCard(
                            moduleName: "Module 1",
                            dataStream:
                                _firebaseService.getModuleData('module1'),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/user_history',
                                arguments: {'module': 'module1'},
                              );
                            },
                          ),
                          const SizedBox(height: defaultPadding),
                          _ModuleChartCard(
                            moduleName: "Module 2",
                            dataStream:
                                _firebaseService.getModuleData('module2'),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/user_history',
                                arguments: {'module': 'module2'},
                              );
                            },
                          ),
                          const SizedBox(height: defaultPadding),
                          _ModuleChartCard(
                            moduleName: "Module 3",
                            dataStream:
                                _firebaseService.getModuleData('module3'),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/user_history',
                                arguments: {'module': 'module3'},
                              );
                            },
                          ),
                          const SizedBox(height: defaultPadding),
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
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const RecentMeasurementsTable(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GPSMapWidget(moduleName: "Module 1"),
                          ),
                          const SizedBox(height: defaultPadding),
                          const _Footer(),
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

  Widget _buildModuleStatusCard(
      String moduleName, IconData icon, Color color, Map<String, bool> status,
      {bool isCompact = false}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(isCompact ? 8 : 16),
        constraints: BoxConstraints(
          minWidth: isCompact ? 80 : 120,
          maxWidth: isCompact ? 110 : 200,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isCompact ? 18 : 24, color: color),
            SizedBox(height: isCompact ? 4 : 8),
            Text(
              moduleName,
              style: TextStyle(
                color: Colors.black87,
                fontSize: isCompact ? 12 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isCompact ? 4 : 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.thermostat,
                  color: status['tempNormal']! ? Colors.green : Colors.red,
                  size: isCompact ? 14 : 20,
                ),
                SizedBox(width: 2),
                Expanded(
                  child: Text(
                    status['tempNormal']! ? 'Suhu Normal' : 'Suhu Tidak Normal',
                    style: TextStyle(
                      fontSize: isCompact ? 9 : 12,
                      color: status['tempNormal']! ? Colors.green : Colors.red,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: isCompact ? 2 : 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.water_drop,
                  color: status['humidityNormal']! ? Colors.green : Colors.red,
                  size: isCompact ? 14 : 20,
                ),
                SizedBox(width: 2),
                Expanded(
                  child: Text(
                    status['humidityNormal']!
                        ? 'Kelembaban Normal'
                        : 'Kelembaban Tidak Normal',
                    style: TextStyle(
                      fontSize: isCompact ? 9 : 12,
                      color:
                          status['humidityNormal']! ? Colors.green : Colors.red,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertSection extends StatelessWidget {
  final String Function(String) getCombinedAlertMessage;
  final Widget Function(String, bool) buildAlertNotification;

  const _AlertSection({
    required this.getCombinedAlertMessage,
    required this.buildAlertNotification,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Builder(
          builder: (context) {
            String tempMessage = getCombinedAlertMessage('temp');
            if (tempMessage.isNotEmpty) {
              return buildAlertNotification(tempMessage, true);
            }
            return const SizedBox.shrink();
          },
        ),
        Builder(
          builder: (context) {
            String humidityMessage = getCombinedAlertMessage('humidity');
            if (humidityMessage.isNotEmpty) {
              return buildAlertNotification(humidityMessage, true);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _ModuleChartCard extends StatelessWidget {
  final String moduleName;
  final Stream<List<SensorReading>> dataStream;
  final VoidCallback onTap;

  const _ModuleChartCard({
    required this.moduleName,
    required this.dataStream,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            moduleName: moduleName,
            moduleId: moduleName == "Module 1"
                ? 'module1'
                : moduleName == "Module 2"
                    ? 'module2'
                    : 'module3',
            onTapModule: onTap,
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: Text(
            "© 2025 I-SAWIT | All rights reserved",
            style: TextStyle(color: Colors.black38, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          "Hubungi: admin@sawit.com | v1.0.0",
          style: TextStyle(color: Colors.black26, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
