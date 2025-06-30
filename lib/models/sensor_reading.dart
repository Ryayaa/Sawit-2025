import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tambahkan ini untuk parsing tanggal

class SensorReading {
  final double temperature;
  final double humidity;
  final DateTime timestamp;

  SensorReading({
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });

  // Properti untuk tanggal dan jam hasil pembulatan
  String get dateString => DateFormat('yyyy-MM-dd').format(timestamp);

  String get roundedHourString {
    int hour = timestamp.hour;
    int minute = timestamp.minute;
    // Pembulatan jam
    if (minute >= 50) {
      hour = (hour + 1) % 24;
    }
    // Format jam:menit
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Parsing timestamp dengan format "yyyy-MM-dd HH:mm:ss"
    DateTime? parseTimestamp(dynamic value) {
      if (value is String) {
        try {
          return DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    final timestamp = parseTimestamp(json['timestamp']);
    if (timestamp == null) {
      // Data tidak valid, return null
      throw FormatException('Invalid timestamp format');
    }

    return SensorReading(
      temperature: parseDouble(json['temperature']),
      humidity: parseDouble(json['humidity']),
      timestamp: timestamp,
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
    // TODO: Ganti dengan pengambilan data asli dari database
    final List<Map<String, dynamic>> rawData = [
      // Contoh data
      {
        "temperature": "30.00",
        "humidity": "75.90",
        "timestamp": "2025-06-29 19:14:59"
      },
      {
        "temperature": "31.10",
        "humidity": "80.00",
        "timestamp": "484" // Ini akan diabaikan
      },
    ];

    // Filter dan parsing hanya data dengan timestamp valid
    List<SensorReading> readings = [];
    for (var item in rawData) {
      try {
        readings.add(SensorReading.fromJson(item));
      } catch (_) {
        // Abaikan data tidak valid
      }
    }
    return readings;
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
