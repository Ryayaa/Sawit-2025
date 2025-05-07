import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../main/components/side_menu.dart';
import 'package:provider/provider.dart';
import '../../controllers/menu_app_controller.dart';
import '../../constants.dart';
import '../../responsive.dart';
import 'components/header.dart';
import 'components/live_chart.dart';
import 'components/cuaca_besok_widget.dart';
import 'components/recent_measurements_table.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show side menu only on desktop mode
            if (Responsive.isDesktop(context))
              const Expanded(
                flex: 1,
                child: SideMenu(),
              ),
            // Main content
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                primary: false,
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  children: [
                    // Header with menu button
                    const Header(),
                    const SizedBox(height: defaultPadding),

                    // Widget cuaca dan suhu
                    const CuacaBesokWidget(
                      suhuTerkini: '30',
                      ramalanBesok: 'Cerah berawan',
                    ),
                    const SizedBox(height: defaultPadding),

                    // Modul 1
                    LiveChart(
                      moduleName: 'Modul 1',
                      temperatureData: [
                        FlSpot(0, 28),
                        FlSpot(1, 29),
                        FlSpot(2, 30),
                        FlSpot(3, 28.5),
                      ],
                      humidityData: [
                        FlSpot(0, 60),
                        FlSpot(1, 62),
                        FlSpot(2, 64),
                        FlSpot(3, 63),
                      ],
                      temperatureLabel: 'Suhu (°C)',
                      humidityLabel: 'Kelembapan (%)',
                      yInterval: 10,
                    ),
                    const SizedBox(height: defaultPadding),

                    // Modul 2
                    LiveChart(
                      moduleName: 'Modul 2',
                      temperatureData: [
                        FlSpot(0, 29),
                        FlSpot(1, 30),
                        FlSpot(2, 28),
                        FlSpot(3, 27.5),
                      ],
                      humidityData: [
                        FlSpot(0, 65),
                        FlSpot(1, 66),
                        FlSpot(2, 67),
                        FlSpot(3, 68),
                      ],
                      temperatureLabel: 'Suhu (°C)',
                      humidityLabel: 'Kelembapan (%)',
                      yInterval: 10,
                    ),
                    const SizedBox(height: defaultPadding),

                    // Modul 3
                    LiveChart(
                      moduleName: 'Modul 3',
                      temperatureData: [
                        FlSpot(0, 26),
                        FlSpot(1, 27),
                        FlSpot(2, 27.5),
                        FlSpot(3, 28),
                      ],
                      humidityData: [
                        FlSpot(0, 70),
                        FlSpot(1, 69),
                        FlSpot(2, 68),
                        FlSpot(3, 67),
                      ],
                      temperatureLabel: 'Suhu (°C)',
                      humidityLabel: 'Kelembapan (%)',
                      yInterval: 10,
                    ),
                    const SizedBox(height: defaultPadding),

                    // Tabel data terbaru
                    RecentMeasurementsTable(
                      initialMeasurements: [
                        {'module': 1, 'temperature': 30, 'soilMoisture': 68},
                        {'module': 2, 'temperature': 29, 'soilMoisture': 71},
                        {'module': 3, 'temperature': 28, 'soilMoisture': 69},
                      ],
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
