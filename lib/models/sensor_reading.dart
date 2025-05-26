class SensorReading {
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final DateTime timestamp;

  SensorReading({
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.timestamp,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      soilMoisture: (json['soilMoisture'] ?? 0).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
    );
  }
}
