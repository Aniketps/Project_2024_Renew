import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SubMap extends StatefulWidget {
  const SubMap({super.key});

  @override
  State<SubMap> createState() => _SubMapState();
}

class _SubMapState extends State<SubMap> {
  List<LatLng> tappedPoints = [
    LatLng(18.584182, 73.964446),
    LatLng(18.575598, 73.990024),
    LatLng(18.588371, 74.000023),
  ];
  List<LatLng> chefmarker = [
    LatLng(18.5773174, 73.9775144),
    LatLng(18.585280, 73.984445),
    LatLng(18.584141, 73.971699),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Map with Markers"),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(18.55, 73.98), // Initial center location
          zoom: 13.0,                   // Initial zoom level
          minZoom: 3,                   // Minimum zoom level
          maxZoom: 30,                  // Maximum zoom level
          onTap: (tapPosition, point) {
            setState(() {
              tappedPoints.add(point);   // Add tapped point to the list
              debugPrint(point.toString());
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          MarkerLayer(
            markers: tappedPoints.map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                  Icons.location_history_outlined,
                  color: Colors.red,
                  size: 25.0,
                ),
              ),
            ).toList(),
          ),
          MarkerLayer(
            markers: chefmarker.map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                  Icons.location_history_outlined,
                  color: Colors.blue,
                  size: 25.0,
                ),
              ),
            ).toList(),
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: [
                  LatLng(18.550, 73.980),
                  LatLng(18.552, 73.982),
                  LatLng(18.555, 73.980),
                  LatLng(18.550, 73.978),
                ],
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          )
        ],
      ),
    );
  }
}