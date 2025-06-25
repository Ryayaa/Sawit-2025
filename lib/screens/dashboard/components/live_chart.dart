import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/sensor_reading.dart';

class LiveChart extends StatelessWidget {
  final String moduleName;
  final Stream<List<SensorReading>> dataStream;

  const LiveChart({
    Key? key,
    required this.moduleName,
    required this.dataStream,
  }) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SensorReading>>(
      stream: dataStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final readings = snapshot.data!;

        return Column(
          children: [
            Text(
              moduleName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3A7D44),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 10,
                    verticalInterval: 1,
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= readings.length) {
                            return const Text('');
                          }

                          // Get current hour
                          final currentHour = DateTime.now().hour;
                          // Calculate hour for this point by subtracting from current hour
                          final pointHour = (currentHour -
                                  (readings.length - 1 - value.toInt())) %
                              24;

                          return Text(
                            '${pointHour.toString().padLeft(2, '0')}:00',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: readings.length.toDouble() - 1,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    // Sort readings by timestamp first
                    ...() {
                      final sortedReadings = readings.toList()
                        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

                      return [
                        // Suhu
                        LineChartBarData(
                          spots: sortedReadings.asMap().entries.map((e) {
                            return FlSpot(
                                e.key.toDouble(), e.value.temperature);
                          }).toList(),
                          isCurved: true,
                          color: Colors.red,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                        // Kelembaban Tanah
                        LineChartBarData(
                          spots: sortedReadings.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value.humidity);
                          }).toList(),
                          isCurved: true,
                          color: Colors.blue,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ];
                    }(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _LegendItem(color: Colors.red, label: 'Suhu'),
                SizedBox(width: 16),
                _LegendItem(color: Colors.blue, label: 'Kelembaban Tanah'),
              ],
            ),
            const SizedBox(height: 20),
            // Add current values
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Suhu Terkini',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${readings.last.temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Kelembapan Tanah',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${readings.last.humidity.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
