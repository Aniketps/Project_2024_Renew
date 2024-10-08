import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  String lat = '';
  String long = '';
  String locationMessage = "Check current location";
  bool LoaderCheck = false;

  Future<void> _openmap(String lat, String long) async {
    String googleURL = "https://www.google.com/maps/search/?api=1&query=$lat,$long";
    await canLaunchUrlString(googleURL) ? await launchUrlString(googleURL): throw "couldMap not launch google $googleURL";
  }
  @override
  void initState() {
    super.initState();
    void _liveLocation() {
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position position) {
          setState(() async {
            String lat = position.latitude.toString();
            String long = position.longitude.toString();
            User? user = FirebaseAuth.instance.currentUser;

            await FirebaseFirestore.instance.collection('user').doc(user?.uid).update({
              'lat' : lat,
              'long' : long,
            });
          });
        },
      );
    };
    _liveLocation();
  }


  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationMessage = "Location services are disabled.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationMessage = "Location permissions are denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationMessage =
        "Location permissions are permanently denied, we cannot request.";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      lat = '${position.latitude}';
      long = '${position.longitude}';
      locationMessage = "Latitude: $lat, Longitude: $long";
      LoaderCheck = !LoaderCheck;
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
      body: LoaderCheck? Center(child: CircularProgressIndicator()) : Container(
        height: screenheight * 0.8,
        width: screenwidth * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              locationMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){
                setState(() {
                  _getCurrentLocation();
                  LoaderCheck = !LoaderCheck;
                });
                },
              child: const Text("Get Current Location"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){
                setState(() {

                  _openmap(lat, long);
                });
              },
              child: const Text("open map"),
            ),
          ],
        ),
      ),
    );
  }
}
