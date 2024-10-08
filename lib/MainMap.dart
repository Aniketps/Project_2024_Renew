import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {

  List<LatLng> AvailableStaff = [];

  late double lat;
  late double long;
  String locationMessage = "Check current location";
  bool LoaderCheck = false;

  @override
  void initState() {
    super.initState();
    LoaderCheck = !LoaderCheck;
    void _liveLocation() {
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position position) {
          setState(() async {
            lat = position.latitude;
            long = position.longitude;
            User? user = FirebaseAuth.instance.currentUser;

            await FirebaseFirestore.instance.collection('user').doc(user?.uid).update({
              'lat' : position.latitude.toString(),
              'long' : position.longitude.toString(),
            });
          });
        },
      );
    };
    _liveLocation();
    getStaffLocation();
    LoaderCheck = !LoaderCheck;
  }

  Future<void> getStaffLocation() async {
    Stream<QuerySnapshot<Map<String, dynamic>>> querySnapshot = FirebaseFirestore.instance.collection("user").snapshots();

    querySnapshot.listen((snapshot) async {
      for (var doc in snapshot.docs) {
        var data = doc.data();
        if(data['lat'] != null && data['long'] != null && data['professionOfStaff'] != null){
          DocumentSnapshot<Map<String, dynamic>> documentReference = await FirebaseFirestore.instance.collection(data['professionOfStaff']).doc(doc.id).get();
          var StatffsData = documentReference.data();
          if(StatffsData?['Status']==true){
            double p1 = double.parse(data['lat']);
            double p2 = double.parse(data['long']);
            setState(() {
              AvailableStaff.add(LatLng(p1, p2));
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenwidth = mediaquery.size.width;
    final screenheight = mediaquery.size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Current Location"),
      ),
      body: LoaderCheck? Center(child: CircularProgressIndicator()) : FlutterMap(
          options: MapOptions(
            initialZoom: 14,
            maxZoom: 18,
            minZoom: 3,
            center: LatLng(18.577401, 73.9774084),
          ), children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(
            markers: AvailableStaff.map(
                (item)=> Marker(
                    point: item,
                    width: 80,
                    height: 80,
                    child: Icon(
                      Icons.location_history,
                      size: 30,
                      color: Colors.red,)
        )
            ).toList(),
        ),
      ]),
    );
  }
}
