import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_civic/services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<dynamic> _locations = [];
  List<dynamic> _zones = [];
  List<dynamic> _workers = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  final MapController _mapController = MapController();

  static const List<Color> _zoneColors = [
    Color(0xFF4F46E5), Color(0xFF059669), Color(0xFFD97706),
    Color(0xFFDC2626), Color(0xFF7C3AED), Color(0xFF0891B2),
  ];

  @override
  void initState() {
    super.initState();
    _fetchMapData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) => _fetchMapData());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMapData() async {
    try {
      final zones = await ApiService.getZones();
      List<dynamic> locations = [];
      List<dynamic> workers = [];
      try { locations = await ApiService.getLocations(); } catch (_) {}
      try { workers = await ApiService.getWorkers(); } catch (_) {}

      if (mounted) {
        setState(() {
          _zones = zones;
          _locations = locations;
          _workers = workers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Polygon> _buildZonePolygons() {
    List<Polygon> polygons = [];
    for (int i = 0; i < _zones.length; i++) {
      final zone = _zones[i];
      final polygon = zone['polygon'];
      if (polygon != null && polygon is List && polygon.isNotEmpty) {
        final Color color = _zoneColors[i % _zoneColors.length];
        List<LatLng> points = [];
        for (var point in polygon) {
          points.add(LatLng(
            double.tryParse(point['lat'].toString()) ?? 0,
            double.tryParse(point['lng'].toString()) ?? 0,
          ));
        }
        if (points.isNotEmpty) {
          polygons.add(Polygon(
            points: points,
            color: color.withValues(alpha: 0.15),
            borderColor: color,
            borderStrokeWidth: 2.5,
          ));
        }
      }
    }
    return polygons;
  }

  List<Marker> _buildWorkerMarkers() {
    return _locations.map<Marker>((loc) {
      final lat = double.tryParse(loc['latitude'].toString()) ?? 0;
      final lng = double.tryParse(loc['longitude'].toString()) ?? 0;
      final isInside = loc['is_inside_zone'] == true;
      final name = loc['name'] ?? 'Worker';

      return Marker(
        width: 120, height: 65,
        point: LatLng(lat, lng),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isInside ? Colors.green.shade700 : Colors.red.shade700,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            ),
            Icon(Icons.location_on, color: isInside ? Colors.green : Colors.red, size: 32,
              shadows: const [Shadow(color: Colors.black38, blurRadius: 6)]),
          ],
        ),
      );
    }).toList();
  }

  List<Marker> _buildZoneLabels() {
    List<Marker> labels = [];
    for (int i = 0; i < _zones.length; i++) {
      final zone = _zones[i];
      final polygon = zone['polygon'];
      if (polygon == null || polygon is! List || polygon.isEmpty) continue;

      double centerLat = 0, centerLng = 0;
      for (var p in polygon) {
        centerLat += (double.tryParse(p['lat'].toString()) ?? 0);
        centerLng += (double.tryParse(p['lng'].toString()) ?? 0);
      }
      centerLat /= polygon.length;
      centerLng /= polygon.length;
      final Color color = _zoneColors[i % _zoneColors.length];

      labels.add(Marker(
        width: 140, height: 50,
        point: LatLng(centerLat, centerLng),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: 2),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(zone['name'] ?? 'Zone ${i + 1}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
              Text('${zone['worker_count'] ?? 0} workers', style: TextStyle(color: Colors.grey.shade600, fontSize: 9)),
            ],
          ),
        ),
      ));
    }
    return labels;
  }

  // ─────────── ASSIGN ZONE DIALOG ───────────
  void _showAssignZoneDialog() {
    int? selectedWorkerId;
    int? selectedZoneId;
    bool assigning = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(children: [
              Icon(Icons.person_pin_circle, color: Colors.indigo.shade600),
              const SizedBox(width: 8),
              const Text('Assign Worker to Zone'),
            ]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Worker dropdown
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Select Worker',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  items: _workers.map<DropdownMenuItem<int>>((w) {
                    return DropdownMenuItem<int>(
                      value: w['id'] is int ? w['id'] : int.tryParse(w['id'].toString()),
                      child: Text(w['name'] ?? 'Worker ${w['id']}'),
                    );
                  }).toList(),
                  onChanged: (v) => setDialogState(() => selectedWorkerId = v),
                ),
                const SizedBox(height: 16),
                // Zone dropdown
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Select Zone',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.map),
                  ),
                  items: _zones.map<DropdownMenuItem<int>>((z) {
                    return DropdownMenuItem<int>(
                      value: z['id'] is int ? z['id'] : int.tryParse(z['id'].toString()),
                      child: Text(z['name'] ?? 'Zone ${z['id']}'),
                    );
                  }).toList(),
                  onChanged: (v) => setDialogState(() => selectedZoneId = v),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton.icon(
                icon: assigning
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check),
                label: Text(assigning ? 'Assigning...' : 'Assign'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: (selectedWorkerId == null || selectedZoneId == null || assigning)
                    ? null
                    : () async {
                        setDialogState(() => assigning = true);
                        try {
                          await ApiService.assignWorkerZone(selectedWorkerId!, selectedZoneId!);
                          if (mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Worker assigned to zone!'), backgroundColor: Colors.green),
                            );
                            _fetchMapData();
                          }
                        } catch (e) {
                          setDialogState(() => assigning = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final insideCount = _locations.where((l) => l['is_inside_zone'] == true).length;
    final outsideCount = _locations.where((l) => l['is_inside_zone'] != true).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Worker Tracking', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.indigo.shade700, Colors.indigo.shade500])),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () { setState(() => _isLoading = true); _fetchMapData(); }),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: const MapOptions(initialCenter: LatLng(18.5204, 73.8567), initialZoom: 14),
                  children: [
                    TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", userAgentPackageName: 'com.example.smart_civic'),
                    PolygonLayer(polygons: _buildZonePolygons()),
                    MarkerLayer(markers: _buildZoneLabels()),
                    MarkerLayer(markers: _buildWorkerMarkers()),
                  ],
                ),

                // Stats bar
                Positioned(
                  top: 12, left: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.radar, color: Colors.indigo.shade600),
                        const SizedBox(width: 8),
                        Text('${_zones.length}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade700)),
                        Text(' Zones', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        const SizedBox(width: 16),
                        Container(width: 1, height: 20, color: Colors.grey.shade300),
                        const SizedBox(width: 12),
                        Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text('$insideCount', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text('$outsideCount', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                          child: Row(children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            const Text('LIVE', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),

                // Legend
                Positioned(
                  bottom: 80, left: 12,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Legend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 6),
                        _legendItem(Colors.green, Icons.location_on, 'In-Zone Worker'),
                        _legendItem(Colors.red, Icons.location_on, 'Outside Zone'),
                        const SizedBox(height: 4),
                        ..._zones.asMap().entries.map((e) {
                          final color = _zoneColors[e.key % _zoneColors.length];
                          return _legendItem(color, Icons.crop_square, e.value['name'] ?? 'Zone ${e.key + 1}');
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),

      // Assign Zone FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAssignZoneDialog,
        backgroundColor: Colors.indigo.shade600,
        icon: const Icon(Icons.person_pin_circle, color: Colors.white),
        label: const Text('Assign Zone', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _legendItem(Color color, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ]),
    );
  }
}