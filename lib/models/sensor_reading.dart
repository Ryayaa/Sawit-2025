import 'package:flutter/material.dart';

class SensorReading {
  final double temperature;
  final double soilMoisture;
  final double humidity;
  final DateTime timestamp;

  SensorReading({
    required this.temperature,
    required this.soilMoisture,
    required this.humidity,
    required this.timestamp,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      temperature: _parseDoubleValue(json['temperature']),
      soilMoisture: _parseDoubleValue(json['soilMoisture']),
      humidity: _parseDoubleValue(json['humidity'] ?? '0.0'),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          _parseIntValue(json['timestamp'])),
    );
  }

  static double _parseDoubleValue(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0.0;
  }

  static int _parseIntValue(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.parse(value);
    return 0;
  }
}

class SensorPage extends StatefulWidget {
  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  late Future<List<SensorReading>> _readingsFuture;
  final Map<String, bool> _moduleAlerts = {};

  @override
  void initState() {
    super.initState();
    _readingsFuture = _fetchSensorReadings();
  }

  Future<List<SensorReading>> _fetchSensorReadings() async {
    // Implementasi pengambilan data sensor
    // Return empty list as placeholder
    return [];
  }

  Future<void> _refreshData() async {
    try {
      setState(() {
        // Reset alerts
        _moduleAlerts.updateAll((key, value) => false);
      });

      // Optional: Tambahkan logika refresh khusus
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _showErrorDialog('Gagal memperbarui data: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Readings'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: FutureBuilder<List<SensorReading>>(
        future: _readingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final readings = snapshot.data!;
            return ListView.builder(
              itemCount: readings.length,
              itemBuilder: (context, index) {
                final reading = readings[index];
                return ListTile(
                  title: Text(
                    'Temperature: ${reading.temperature} °C, '
                    'Humidity: ${reading.humidity} %, '
                    'Soil Moisture: ${reading.soilMoisture} %',
                  ),
                  subtitle: Text('Timestamp: ${reading.timestamp}'),
                  trailing: _buildAlertIcon(reading),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildAlertIcon(SensorReading reading) {
    // Logika untuk menentukan apakah akan menampilkan ikon peringatan
    return Container();
  }
}
