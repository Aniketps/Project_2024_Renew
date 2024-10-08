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
 List<LatLng>RegisteredNurseMarker = [LatLng(18.591248, 74.000139)];

  List<LatLng> LicensdePracticalNurseMarker = [LatLng(18.576116, 73.972072)];

  List<LatLng>CertifiedNursAssistentMarker = [LatLng(18.367661, 73.784233)];

 List<LatLng> HomeHealthAidesMarker = [LatLng(18.482109, 73.868007)];

List<LatLng> PhysiotherapistsMarker = [LatLng(18.543242, 73.922786)];

List<LatLng> OccupationalTherapistsMarker = [LatLng(18.570415, 73.918444)];

List<LatLng>ParamedicsMarker = [LatLng(18.565543, 73.936531)];

List<LatLng> DisabledCaregiversMarker = [LatLng(18.582879, 73.984277)];

List<LatLng> CooksMarker = [LatLng(18.553016, 73.887723)];

List<LatLng> HousekeepersMarker = [LatLng(18.553527, 73.949120)];

 List<LatLng> CleaningStaffMarker = [LatLng(18.496048, 73.872785)];

List<LatLng> BabysittersMarker = [LatLng(18.591861, 73.939677)];

List<LatLng> ElderCompanionsMarker = [LatLng(18.501442, 73.934076)];

List<LatLng>HomeGuardsMarker = [LatLng(18.716868, 73.485374)];

List<LatLng>SecurityGuardsMarker = [LatLng(18.721646, 73.342125)];

List<LatLng>PersonalCareAssistantsMarker = [LatLng(18.739626, 73.425736)];

List<LatLng>DriverMarker = [LatLng(18.973073, 74.438641)];

List<LatLng>AdministrativeAssistantsMarker = [LatLng(18.658596, 74.158867)];

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
                   Icons.person_pin,
                  color: const Color.fromRGBO(253, 232, 45, 1),
                  size: 30.0,
                ),
              ),
            ).toList(),
          ),
          MarkerLayer(
            markers: LicensdePracticalNurseMarker.map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                   Icons.person_pin,
                  color: const Color.fromARGB(255, 3, 94, 230),
                  size: 30.0,

                ),
              ),
            ).toList(),
          ),
   MarkerLayer(
            markers:CertifiedNursAssistentMarker.map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                   Icons.person_pin,
                  color: Colors.purple,
                  size: 30.0,

                ),
              ),
            ).toList(),
          ),
          MarkerLayer(
            markers:HomeHealthAidesMarker .map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                   Icons.person_pin,
                  color: Colors.blue,
                  size: 30.0,
                ),
              ),
            ).toList(),
          ),
          MarkerLayer(
            markers:PhysiotherapistsMarker.map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                   Icons.person_pin,
                  color: Colors.black,
                  size: 30.0,
                ),
              ),
            ).toList(),
          ),
 MarkerLayer(
            markers: OccupationalTherapistsMarker.map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                   Icons.person_pin,
                  color: Colors.green,
                  size: 30.0,
                ),
              ),
            ).toList(),
          ),
 MarkerLayer(
            markers:ParamedicsMarker.map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                 Icons.person_pin,
                  color: Colors.brown,
                  size: 30.0,

                ),
              ),

            ).toList(),
          ),
 MarkerLayer(
            markers:DisabledCaregiversMarker .map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                   Icons.person_pin,
                  color: Colors.pink,
                  size: 30.0,
                ),
              ),
            ).toList(),
          ),
MarkerLayer(
            markers:CooksMarker .map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                   Icons.person_pin,
                  color: const Color.fromRGBO(240, 181, 177, 1),
                  size: 30.0,
                ),
              ),
            ).toList(),
          ),
MarkerLayer(
            markers:HousekeepersMarker .map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                   Icons.person_pin,
                  color: const Color.fromARGB(255, 234, 132, 132),
                  size: 30.0,
                ),
              ),
            ).toList(),
          ),
MarkerLayer(
            markers: CleaningStaffMarker.map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                   Icons.person_pin,
                  color: const Color.fromARGB(183, 226, 43, 30),
                  size: 30.0,
                ),
              ),
            ).toList(),
          ),
MarkerLayer(
            markers:BabysittersMarker.map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                   Icons.person_pin,
                  color: const Color.fromARGB(255, 2, 242, 10),
                  size: 30.0,
                ),
              ),
            ).toList(),
          ),
MarkerLayer(
            markers:ElderCompanionsMarker.map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                   Icons.person_pin,
                  color: const Color.fromARGB(255, 3, 86, 153),
                  size: 30.0,
                ),
              ),
            ).toList(),
          ),
MarkerLayer(
            markers:HomeGuardsMarker.map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                   Icons.person_pin,
                  color: Colors.red,
                  size: 30.0,
                ),
              ),
            ).toList(),
          ),
MarkerLayer(
            markers:SecurityGuardsMarker.map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                   Icons.person_pin,
                  color: Colors.blueGrey,
                  size: 30.0,
                ),
              ),
            ).toList(),
          ),
MarkerLayer(
            markers:PersonalCareAssistantsMarker.map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                   Icons.person_pin,
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
            ).toList(),
          ),
MarkerLayer(
            markers:DriverMarker.map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                   Icons.person_pin,
                  color: const Color.fromARGB(255, 119, 2, 41),
                  size: 30.0,
                ),
              ),
            ).toList(),
          ),
MarkerLayer(
            markers:AdministrativeAssistantsMarker.map(
                  (point) => Marker(
                point: point,
                width: 80.0,
                height: 80.0,
                child: Icon(
                   Icons.person_pin,
                  color: const Color.fromARGB(255, 25, 0, 29),
                  size: 30.0,
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