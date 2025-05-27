class GPSCoordinate {
  final double latitude;
  final double longitude;
  final int? lastUpdate;

  GPSCoordinate({
    required this.latitude,
    required this.longitude,
    this.lastUpdate,
  });

  factory GPSCoordinate.fromMap(Map<String, dynamic> map) {
    return GPSCoordinate(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      lastUpdate: map['last_update'] as int?,
    );
  }
}
