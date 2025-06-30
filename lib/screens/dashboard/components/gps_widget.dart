import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';

// Tambahkan parameter opsional jika ingin dinamis
class GPSMapWidget extends StatefulWidget {
  final String moduleName;
  const GPSMapWidget({super.key, this.moduleName = "Module 1"});

  @override
  State<GPSMapWidget> createState() => _GPSMapWidgetState();
}

class _GPSMapWidgetState extends State<GPSMapWidget> {
  LatLng? _currentLocation;
  String? _lastUpdate;
  bool _loading = true;
  final MapController _mapController = MapController();
  double _zoom = 13.0;

  @override
  void initState() {
    super.initState();
    _listenToGPS();
  }

  void _listenToGPS() {
    FirebaseDatabase.instance
        .ref()
        .child('module1/latest_gps')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        final map = Map<String, dynamic>.from(data as Map);
        final lat = double.tryParse(map['latitude'].toString());
        final lng = double.tryParse(map['longitude'].toString());
        final lastUpdate = map['last_update']?.toString();
        if (lat != null && lng != null) {
          setState(() {
            _currentLocation = LatLng(lat, lng);
            _lastUpdate = lastUpdate;
            _loading = false;
          });
        }
      }
    });
  }

  void _zoomIn() {
    setState(() {
      _zoom += 1;
      _mapController.move(_currentLocation!, _zoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoom -= 1;
      _mapController.move(_currentLocation!, _zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "GPS (${widget.moduleName})",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_currentLocation == null)
          const Center(child: Text('Belum ada data GPS'))
        else ...[
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation!,
                      initialZoom: _zoom,
                      minZoom: 2,
                      maxZoom: 18,
                      interactiveFlags: InteractiveFlag.all,
                      onPositionChanged: (pos, hasGesture) {
                        setState(() {
                          _zoom = pos.zoom ?? _zoom;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentLocation!,
                            width: 80,
                            height: 60,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    widget.moduleName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Tombol zoom in/out
                Positioned(
                  top: 10,
                  right: 10,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'zoomIn',
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: _zoomIn,
                        child: const Icon(Icons.add, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'zoomOut',
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: _zoomOut,
                        child: const Icon(Icons.remove, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_lastUpdate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Update terakhir: $_lastUpdate",
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
        ],
      ],
    );
  }
}
