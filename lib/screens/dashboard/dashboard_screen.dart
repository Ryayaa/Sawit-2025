import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../constants.dart';
import '../../responsive.dart';

import 'components/header.dart';
import 'components/live_chart.dart';
import 'components/cuaca_besok_widget.dart';
import 'components/recent_files.dart';
import 'components/storage_details.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const Header(),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cuaca besok + suhu terkini
                      const CuacaBesokWidget(
                        suhuTerkini: '30', // bisa diganti dengan data dari API
                        ramalanBesok: 'Cerah berawan',
                      ),
                      const SizedBox(height: defaultPadding),

                      // Grafik suhu & kelembapan
                      LiveChart(
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
                      ),
                      const SizedBox(height: defaultPadding),

                      // File atau data terakhir
                      const RecentFiles(),

                      if (Responsive.isMobile(context))
                        const SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context)) const StorageDetails(),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  const SizedBox(width: defaultPadding),
                if (!Responsive.isMobile(context))
                  const Expanded(
                    flex: 2,
                    child: StorageDetails(),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
