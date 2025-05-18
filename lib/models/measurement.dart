class Measurement {
  final DateTime timestamp;
  final String moduleId;
  final double temperature;
  final double soilMoisture;
  final double humidity;
  final String gpsTime;
  final double latitude;
  final double longitude;

  Measurement({
    required this.timestamp,
    required this.moduleId,
    required this.temperature,
    required this.soilMoisture,
    required this.humidity,
    required this.gpsTime,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'moduleId': moduleId,
      'temperature': temperature,
      'soilMoisture': soilMoisture,
      'humidity': humidity,
      'gpsTime': gpsTime,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      moduleId: map['moduleId'] ?? '',
      temperature: (map['temperature'] ?? 0).toDouble(),
      soilMoisture: (map['soilMoisture'] ?? 0).toDouble(),
      humidity: (map['humidity'] ?? 0).toDouble(),
      gpsTime: map['gps_time'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
    );
  }
}
