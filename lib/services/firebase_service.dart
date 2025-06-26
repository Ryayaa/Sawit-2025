import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/sensor_reading.dart';
import '../models/gps_coordinate.dart';
import '../models/sensor_data.dart';
import '../services/cache_service.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final CacheService _cacheService = CacheService();

  // Optimasi stream data sensor dengan caching dan batasan data
  Stream<List<SensorReading>> getModuleData(String moduleId) {
    return _database
        .child('$moduleId/readings')
        .orderByChild('timestamp')
        .limitToLast(24)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      try {
        final List<SensorReading> readings = [];
        data.forEach((key, value) {
          if (value is Map) {
            try {
              final reading = Map<String, dynamic>.from(value as Map);
              readings.add(SensorReading.fromJson(reading));
            } catch (e) {
              print('Error parsing individual reading: $e');
            }
          }
        });

        return readings..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } catch (e) {
        print('Error parsing data: $e');
        return [];
      }
    });
  }

  // Fix method getLatestReadings
  Future<List<SensorReading>> getLatestReadings(String moduleId) async {
    try {
      final snapshot = await _database
          .child('$moduleId/readings')
          .orderByChild('timestamp')
          .limitToLast(1)
          .get();

      if (!snapshot.exists || snapshot.value == null) return [];

      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((e) {
        final reading = e.value as Map<dynamic, dynamic>;
        return SensorReading(
          temperature: _parseDouble(reading['temperature']),
          humidity: _parseDouble(reading['humidity']),
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            _parseInt(reading['timestamp']),
          ),
        );
      }).toList();
    } catch (e) {
      print('Error getting latest readings: $e');
      return [];
    }
  }

  // Fix method updateSensorReading
  Future<void> updateSensorReading(
      String moduleId, SensorReading reading) async {
    try {
      await _database.child('$moduleId/readings').push().set({
        'temperature': reading.temperature,
        'humidity': reading.humidity,
        'timestamp': reading.timestamp.millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error updating sensor reading: $e');
      throw Exception('Failed to update sensor reading');
    }
  }

  // Fix method getLatestReading
  Future<SensorReading?> getLatestReading(String moduleId) async {
    try {
      final snapshot = await _database
          .child('$moduleId/readings')
          .orderByChild('timestamp')
          .limitToLast(1)
          .get();

      if (!snapshot.exists || snapshot.value == null) return null;

      final Map<dynamic, dynamic> value =
          snapshot.value as Map<dynamic, dynamic>;
      final data = Map<String, dynamic>.from(value.values.first as Map);

      return SensorReading(
        temperature: _parseDouble(data['temperature']),
        humidity: _parseDouble(data['humidity']),
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          _parseInt(data['timestamp']),
        ),
      );
    } catch (e) {
      print('Error getting latest reading: $e');
      return null;
    }
  }

  // Stream untuk semua modul
  Stream<Map<String, List<SensorReading>>> getAllModulesData() {
    return _database.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return {};

      Map<String, List<SensorReading>> allModules = {};

      data.forEach((moduleId, moduleData) {
        if (moduleData is Map && moduleData['readings'] != null) {
          final readings = moduleData['readings'] as Map<dynamic, dynamic>;
          List<SensorReading> moduleReadings = [];
          readings.forEach((key, value) {
            final reading = Map<String, dynamic>.from(value as Map);
            moduleReadings.add(SensorReading.fromJson(reading));
          });
          allModules[moduleId] = moduleReadings;
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

  Stream<GPSCoordinate> getModule1Location() {
    return FirebaseDatabase.instance
        .ref()
        .child('module1/latest_gps')
        .onValue
        .map((event) {
      final data = event.snapshot.value;

      // Tambahkan pengecekan null
      if (data == null) {
        throw Exception('GPS data not found');
      }

      // Konversi data ke Map<String, dynamic>
      final map = Map<String, dynamic>.from(data as Map);

      return GPSCoordinate.fromMap(map);
    });
  }

  Future<void> cacheData(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  Future<SensorData?> getSensorData(String moduleId) async {
    // Cek cache dulu
    if (await _cacheService.isCacheValid('sensor_data_$moduleId')) {
      return await _cacheService.getCachedData<SensorData>(
          'sensor_data_$moduleId', (json) => SensorData.fromJson(json));
    }

    // Jika cache tidak valid, ambil dari Firebase
    try {
      final snapshot = await _database
          .child('$moduleId/readings')
          .orderByChild('timestamp')
          .limitToLast(1)
          .get();

      if (!snapshot.exists) return null;

      final data = snapshot.value as Map<dynamic, dynamic>;
      final sensorData = SensorData.fromJson(data as Map<String, dynamic>);

      // Simpan ke cache
      await _cacheService.cacheData(
          'sensor_data_$moduleId', sensorData.toJson());

      return sensorData;
    } catch (e) {
      print('Error getting sensor data: $e');
      return null;
    }
  }

  // Helper parsing
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
