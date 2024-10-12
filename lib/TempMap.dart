import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TempMap extends StatefulWidget {

  String lat;
  String long;
  TempMap({required this.lat, required this.long});

  @override
  State<TempMap> createState() => _TempMapState(lat: lat, long: long);
}

class _TempMapState extends State<TempMap> {
  String lat;
  String long;
  _TempMapState({required this.lat, required this.long});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Destination"),
        backgroundColor: Colors.red,
      ),
      body: FlutterMap(
          options: MapOptions(
            initialZoom: 14,
            maxZoom: 18,
            minZoom: 3,
            center: LatLng(double.parse(lat), double.parse(long)),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            MarkerLayer(
                markers: [Marker(
                    point: LatLng(double.parse(lat), double.parse(long)),
                    child: Icon(
                      Icons.location_history,
                      color: Colors.red,
                      size: 30.0,
                    ),)]
            ),
          ]),
    );
  }
}
