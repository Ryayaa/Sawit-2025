import 'package:flutter/material.dart';

class SensorReading {
  final double temperature;
  final double humidity;
  final DateTime timestamp;

  SensorReading({
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return SensorReading(
      temperature: parseDouble(json['temperature']),
      humidity: parseDouble(json['humidity']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        parseInt(json['timestamp']),
      ),
    );
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
                    'Humidity: ${reading.humidity} %, ',
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
