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

  List<LatLng> RegisteredNurseMarker = [];
  List<LatLng> LicensdePracticalNurseMarker = [];
  List<LatLng> CertifiedNursAssistentMarker = [];
  List<LatLng> HomeHealthAidesMarker = [];
  List<LatLng> PhysiotherapistsMarker = [];
  List<LatLng> OccupationalTherapistsMarker = [];
  List<LatLng> ParamedicsMarker = [];
  List<LatLng> DisabledCaregiversMarker = [];
  List<LatLng> CooksMarker = [];
  List<LatLng> HousekeepersMarker = [];
  List<LatLng> CleaningStaffMarker = [];
  List<LatLng> BabysittersMarker = [];
  List<LatLng> ElderCompanionsMarker = [];
  List<LatLng> HomeGuardsMarker = [];
  List<LatLng> SecurityGuardsMarker = [];
  List<LatLng> PersonalCareAssistantsMarker = [];
  List<LatLng> DriverMarker = [];
  List<LatLng> AdministrativeAssistantsMarker = [];
  List<LatLng> chefmarker = [];

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

  // skill[0].toLowerCase()+skill.substring(1)

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
              switch(data['professionOfStaff']){
                case 'chef':
                  chefmarker.add(LatLng(p1, p2));
                  break;
                case 'personal Care Assistants':
                  PersonalCareAssistantsMarker.add(LatLng(p1, p2));
                  break;
                case 'driver':
                  DriverMarker.add(LatLng(p1, p2));
                  break;
                case 'security Guards':
                  SecurityGuardsMarker.add(LatLng(p1, p2));
                  break;
                case 'home Guards':
                  HomeGuardsMarker.add(LatLng(p1, p2));
                  break;
                case 'elder Companions':
                  ElderCompanionsMarker.add(LatLng(p1, p2));
                  break;
                case 'babysitters':
                  BabysittersMarker.add(LatLng(p1, p2));
                  break;
                case 'cleaner':
                  CleaningStaffMarker.add(LatLng(p1, p2));
                  break;
                case 'housekeepers':
                  HousekeepersMarker.add(LatLng(p1, p2));
                  break;
                case 'elderly':
                  ElderCompanionsMarker.add(LatLng(p1, p2));
                  break;
                case 'paramedics':
                  ParamedicsMarker.add(LatLng(p1, p2));
                  break;
                case 'occupational Therapists':
                  OccupationalTherapistsMarker.add(LatLng(p1, p2));
                  break;
                case 'physiotherapists':
                  PhysiotherapistsMarker.add(LatLng(p1, p2));
                  break;
                case 'home Health Aides':
                  HomeHealthAidesMarker.add(LatLng(p1, p2));
                  break;
                case 'certified Nursing Assistants':
                  CertifiedNursAssistentMarker.add(LatLng(p1, p2));
                  break;
                case 'licensed Practical Nurses':
                  LicensdePracticalNurseMarker.add(LatLng(p1, p2));
                  break;
                case 'registered Nurses':
                  RegisteredNurseMarker.add(LatLng(p1, p2));
                  break;
              }

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
        title: const Text("Set current Location Check nearest Available Staff", style: TextStyle(fontSize: 15, ),),
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

        // New data

        // Chef
        MarkerLayer(
          markers: chefmarker.map(
                (point) => Marker(
              point: point,
              width: 80.0,
              height: 80.0,
              child: Icon(
                Icons.person_pin,
                color: Colors.yellow,
                size: 30.0,
              ),
            ),
          ).toList(),
        ),

        // Licenade Practical Nurse
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

        // Certified Nurse Assistant
        MarkerLayer(
          markers: CertifiedNursAssistentMarker.map(
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

        // Home Health Aides
        MarkerLayer(
          markers: HomeHealthAidesMarker.map(
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

        // Physiotherapists
        MarkerLayer(
          markers: PhysiotherapistsMarker.map(
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

        // Occupational Therapists
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

        // Paramedics
        MarkerLayer(
          markers: ParamedicsMarker.map(
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
          markers: DisabledCaregiversMarker.map(
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
          markers: CooksMarker.map(
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
          markers: HousekeepersMarker.map(
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
          markers: BabysittersMarker.map(
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
          markers: ElderCompanionsMarker.map(
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
          markers: HomeGuardsMarker.map(
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
          markers: SecurityGuardsMarker.map(
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
          markers: PersonalCareAssistantsMarker.map(
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
          markers: DriverMarker.map(
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
          markers: AdministrativeAssistantsMarker.map(
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
      ]),
    );
  }
}
