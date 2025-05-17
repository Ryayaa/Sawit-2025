import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class SensorService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Stream of real-time sensor data
  Stream<Map<String, dynamic>> getLiveModuleData(String moduleId) {
    return _database
        .child('sensor_modules/$moduleId/latest_reading')
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return {};

      return {
        'temperature': data['temperature'] ?? 0.0,
        'soilMoisture': data['soilMoisture'] ?? 0.0,
        'humidity': data['humidity'] ?? 0.0,
        'timestamp': data['timestamp'] ?? 0,
      };
    });
  }

  // Get historical data
  Stream<List<FlSpot>> getHistoricalData(String dataType) {
    return _database
        .child('sensor_modules/module1/readings')
        .limitToLast(24) // Last 24 readings
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      final List<FlSpot> spots = [];
      var index = 0.0;

      data.forEach((key, value) {
        spots.add(FlSpot(
          index++,
          (value[dataType] ?? 0.0).toDouble(),
        ));
      });

      return spots;
    });
  }
}
