import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class SensorService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Stream of real-time data from "module1/latest"
  Stream<Map<String, dynamic>> getLiveModuleData(String moduleId) {
    return _database
        .child('$moduleId/latest') // Menyesuaikan path sesuai struktur DB
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return {};

      return {
        'temperature': (data['temperature'] ?? 0).toDouble(),
        'soilMoisture': (data['soilMoisture'] ?? 0).toDouble(),
        'humidity': (data['humidity'] ?? 0).toDouble(),
        'timestamp': data['timestamp'] ?? 0,
      };
    });
  }

  // Stream of historical data (misalnya dari "module1" -> data lainnya)
  Stream<List<FlSpot>> getHistoricalData(String moduleId, String dataType) {
    return _database
        .child('$moduleId') // Ambil langsung dari moduleId (misal: module1)
        .orderByKey()
        .onValue
        .map((event) {
      final rawData = event.snapshot.value as Map<dynamic, dynamic>?;

      if (rawData == null) return [];

      final List<FlSpot> spots = [];
      double index = 0;

      // Ambil hanya child yang bukan 'latest'
      rawData.forEach((key, value) {
        if (key != 'latest' && value is Map) {
          final yValue = (value[dataType] ?? 0.0).toDouble();
          spots.add(FlSpot(index++, yValue));
        }
      });

      return spots;
    });
  }
}
