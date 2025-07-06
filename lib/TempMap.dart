import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globle.dart';

class TempMap extends StatefulWidget {
  String lat;
  String long;
  TempMap({super.key, required this.lat, required this.long});

  @override
  State<TempMap> createState() => _TempMapState(lat: lat, long: long);
}

class _TempMapState extends State<TempMap> {
  String lat;
  String long;
  String localityName = "Loading...";
  _TempMapState({required this.lat, required this.long});
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocalityName(double.parse(lat.toString()), double.parse(long.toString()));
  }
  void getLocalityName(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      if (placemarks.isNotEmpty) {
        setState(() {
          localityName = "${placemarks.first.street},${placemarks.first.locality}";
        });
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Destination"),
        backgroundColor: Globle.theme,
      ),
      body: Stack(
        children: [
          FlutterMap(
              options: MapOptions(
                initialZoom: 18,
                maxZoom: 20,
                minZoom: 3,
                center: LatLng(double.parse(lat), double.parse(long)),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://mt.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                ),
                MarkerLayer(markers: [
                  Marker(
                    point: LatLng(double.parse(lat), double.parse(long)),
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 50.0,
                    ),
                  )
                ]),
              ]),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                localityName,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class SelectDestination extends StatefulWidget {
  const SelectDestination({super.key});

  @override
  _SelectDestinationState createState() => _SelectDestinationState();
}

class _SelectDestinationState extends State<SelectDestination> {
  late double currentUserLat;
  late double currentUserLong;
  LatLng selectedLocation = const LatLng(0.0, 0.0);
  String localityName = "Loading...";
  final MapController _mapController = MapController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserCurrentLatLong();
  }

  void getUserCurrentLatLong() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot data = await FirebaseFirestore.instance
            .collection("user")
            .doc(user.uid)
            .get();

        if (data.exists) {
          setState(() {
            currentUserLat = double.tryParse(data['lat'].toString()) ?? 0.0;
            currentUserLong = double.tryParse(data['long'].toString()) ?? 0.0;
            selectedLocation = LatLng(currentUserLat, currentUserLong);
            isLoading = false;
          });

          // ✅ Move map AFTER build to avoid errors
          Future.delayed(const Duration(milliseconds: 300), () {
            _mapController.move(selectedLocation, 16);
          });

          getLocalityName(currentUserLat, currentUserLong);
        } else {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching user location: $e");
      setState(() => isLoading = false);
    }
  }

  void getLocalityName(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      if (placemarks.isNotEmpty) {
        setState(() {
          localityName = "${placemarks.first.street},${placemarks.first.locality}";
        });
      }
    } catch (e) {
    }
  }

  void _saveSelectedLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      prefs.setDouble("SelectedLat", selectedLocation.latitude);
      prefs.setDouble("SelectedLong", selectedLocation.longitude);
      Fluttertoast.showToast(msg: "Location saved: $localityName");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error saving location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Select Destination")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Destination", style: TextStyle(color : Colors.white),),
        backgroundColor: Globle.theme,
      ),
      body: Stack(
        children: [
          // Flutter Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialZoom: 16,
              maxZoom: 20,
              minZoom: 3,
              center: selectedLocation,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    selectedLocation = position.center!;
                    localityName = "Loading..."; // Reset while fetching
                  });

                  // Fetch new locality name
                  getLocalityName(selectedLocation.latitude, selectedLocation.longitude);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://mt.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
              ),
            ],
          ),

          // Centered Marker
          const Center(
            child: Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40.0,
            ),
          ),

          // Locality Name Display
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                localityName,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Confirm Button
          Positioned(
            bottom: 20,
            left: 50,
            right: 50,
            child: ElevatedButton(
              onPressed: (){
                _saveSelectedLocation();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Confirm Location", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}