class Measurement {
  final DateTime timestamp;
  final String moduleId;
  final double temperature;
  final double soilMoisture;

  Measurement({
    required this.timestamp,
    required this.moduleId,
    required this.temperature,
    required this.soilMoisture,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'moduleId': moduleId,
      'temperature': temperature,
      'soilMoisture': soilMoisture,
    };
  }

  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      timestamp: DateTime.parse(map['timestamp']),
      moduleId: map['moduleId'],
      temperature: map['temperature'],
      soilMoisture: map['soilMoisture'],
    );
  }
}
