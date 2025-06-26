import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/sensor_reading.dart';

class LiveChart extends StatelessWidget {
  final String moduleName;
  final Stream<List<SensorReading>> dataStream;
  final VoidCallback? onTapModule; // Tambahkan ini

  const LiveChart({
    Key? key,
    required this.moduleName,
    required this.dataStream,
    this.onTapModule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapModule,
      child: StreamBuilder<List<SensorReading>>(
        stream: dataStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final readings = snapshot.data!;
          if (readings.isEmpty) {
            return const Center(child: Text('Belum ada data'));
          }

          // Sort readings sekali saja
          final sortedReadings = List<SensorReading>.from(readings)
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

          final lastReading = sortedReadings.last;

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
                    gridData: const FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 10,
                      verticalInterval: 1,
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: sortedReadings.length > 8
                              ? (sortedReadings.length / 4).ceilToDouble()
                              : 1,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= sortedReadings.length) {
                              return const Text('');
                            }
                            final currentHour = DateTime.now().hour;
                            final pointHour = (currentHour -
                                    (sortedReadings.length - 1 - value.toInt())) %
                                24;
                            return Transform.rotate(
                              angle: -0.5,
                              child: Text(
                                '${pointHour.toString().padLeft(2, '0')}:00',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.black54,
                                ),
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
                    maxX: sortedReadings.length.toDouble() - 1,
                    minY: 0,
                    maxY: 100,
                    lineBarsData: [
                      // Suhu
                      LineChartBarData(
                        spots: List.generate(
                          sortedReadings.length,
                          (i) => FlSpot(i.toDouble(), sortedReadings[i].temperature),
                        ),
                        isCurved: true,
                        color: Colors.red,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      // Kelembaban Tanah
                      LineChartBarData(
                        spots: List.generate(
                          sortedReadings.length,
                          (i) => FlSpot(i.toDouble(), sortedReadings[i].humidity),
                        ),
                        isCurved: true,
                        color: Colors.blue,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _ChartLegend(),
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
                          '${lastReading.temperature.toStringAsFixed(1)}°C',
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
                          '${lastReading.humidity.toStringAsFixed(1)}%',
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
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _LegendItem(color: Colors.red, label: 'Suhu'),
        SizedBox(width: 16),
        _LegendItem(color: Colors.blue, label: 'Kelembaban Tanah'),
      ],
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
