import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LiveChart extends StatelessWidget {
  final String moduleName;
  final List<FlSpot> temperatureData;
  final List<FlSpot> humidityData;
  final String temperatureLabel;
  final String humidityLabel;
  final double yInterval;
  final double minY;
  final double maxY;

  const LiveChart({
    super.key,
    required this.moduleName,
    required this.temperatureData,
    required this.humidityData,
    this.temperatureLabel = "Temperature",
    this.humidityLabel = "Soil Moisture",
    this.yInterval = 20, // Interval default untuk sumbu Y
    this.minY = 20, // Nilai minimum sumbu Y
    this.maxY = 100, // Nilai maksimum sumbu Y
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              moduleName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(show: true, drawVerticalLine: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 22,
                        getTitlesWidget: (value, _) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: yInterval,
                        getTitlesWidget: (value, _) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.white24),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: temperatureData,
                      isCurved: true,
                      color: Colors.blueAccent,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: humidityData,
                      isCurved: true,
                      color: Colors.greenAccent,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _LegendDot(color: Colors.blueAccent, label: temperatureLabel),
                const SizedBox(width: 16),
                _LegendDot(color: Colors.greenAccent, label: humidityLabel),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        )
      ],
    );
  }
}
