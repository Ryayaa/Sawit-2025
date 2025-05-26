import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_reading.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Stream untuk satu modul spesifik
  Stream<List<SensorReading>> getModuleData(String moduleId) {
    return _database
        .child('$moduleId/readings')
        .orderByChild('timestamp')
        .limitToLast(24) // Last 24 readings
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null || data.isEmpty) return [];

      List<SensorReading> readings = [];
      data.forEach((key, value) {
        if (value != null) {
          final reading = Map<String, dynamic>.from(value as Map);
          readings.add(SensorReading.fromJson(reading));
        }
      });

      return readings..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }

  Future<void> updateSensorReading(
      String moduleId, SensorReading reading) async {
    await _database.child('modules/$moduleId/readings').push().set({
      'temperature': reading.temperature,
      'humidity': reading.humidity,
      'timestamp': reading.timestamp.millisecondsSinceEpoch,
    });
  }

  // Method untuk mendapatkan data terbaru dari modul
  Future<SensorReading?> getLatestReading(String moduleId) async {
    final snapshot = await _database
        .child('$moduleId/readings')
        .orderByChild('timestamp')
        .limitToLast(1)
        .get();

    if (snapshot.value == null) return null;

    final data = Map<String, dynamic>.from(
        (snapshot.value as Map<dynamic, dynamic>).values.first as Map);
    return SensorReading.fromJson(data);
  }

  // Stream untuk semua modul
  Stream<Map<String, List<SensorReading>>> getAllModulesData() {
    return _database.child('modules').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return {};

      Map<String, List<SensorReading>> allModules = {};

      data.forEach((moduleId, moduleData) {
        if (moduleData['readings'] != null) {
          final readings = moduleData['readings'] as Map<dynamic, dynamic>;
          List<SensorReading> moduleReadings = [];

          readings.forEach((key, value) {
            final reading = Map<String, dynamic>.from(value as Map);
            reading['moduleId'] = moduleId;
            moduleReadings.add(SensorReading.fromJson(reading));
          });

          allModules[moduleId] = moduleReadings
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        }
      });

      return allModules;
    });
  }

  // Method untuk memeriksa suhu abnormal
  Stream<List<String>> getAbnormalTemperatureModules() {
    return getAllModulesData().map((modulesData) {
      List<String> abnormalModules = [];

      modulesData.forEach((moduleId, readings) {
        if (readings.isNotEmpty) {
          final lastReading = readings.last;
          if (lastReading.temperature > 35.0) {
            // Suhu di atas 35°C dianggap abnormal
            abnormalModules.add(moduleId);
          }
        }
      });

      return abnormalModules;
    });
  }
}
