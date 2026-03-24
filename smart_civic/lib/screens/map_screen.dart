import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List workers = [];

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/locations"), // use this for emulator
        headers: {
          "Authorization": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiZW1haWwiOiJhZG1pbkB0ZXN0LmNvbSIsInJvbGUiOiJhZG1pbiIsImlhdCI6MTc3NDM4NjExOCwiZXhwIjoxNzc0NDcyNTE4fQ.mRJTACopNenDFVlPxcRMOfeK2M2nqzWiYj8fptC-Mo4"
        },
      );

      final data = jsonDecode(response.body);

      if (data["success"]) {
        setState(() {
          workers = data["locations"];
        });
      }
    } catch (e) {
      print("Error fetching locations: $e");
    }
  }

  List<Marker> buildMarkers() {
    return workers.map<Marker>((worker) {
      final lat = double.parse(worker["latitude"].toString());
      final lng = double.parse(worker["longitude"].toString());
      final isInside = worker["is_inside_zone"];

      return Marker(
        width: 50,
        height: 50,
        point: LatLng(lat, lng),
        child: Icon(
          Icons.location_on,
          color: isInside == true ? Colors.green : Colors.red,
          size: 35,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Worker Tracking"),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(18.5204, 73.8567),
          initialZoom: 13,
        ),
        children: [
          TileLayer(
  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
  userAgentPackageName: 'com.example.smart_civic',
),

          MarkerLayer(
            markers: buildMarkers(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchLocations,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}