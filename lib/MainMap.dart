import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'StaffProfilePage.dart';

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

            await FirebaseFirestore.instance
                .collection('user')
                .doc(user?.uid)
                .update({
              'lat': position.latitude.toString(),
              'long': position.longitude.toString(),
            });
          });
        },
      );
    }

    ;
    _liveLocation();
    getStaffLocation();
    LoaderCheck = !LoaderCheck;
  }

  // skill[0].toLowerCase()+skill.substring(1)

  Future<void> getStaffLocation() async {
    Stream<QuerySnapshot<Map<String, dynamic>>> querySnapshot =
        FirebaseFirestore.instance.collection("user").snapshots();

    querySnapshot.listen((snapshot) async {
      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data['lat'] != null &&
            data['long'] != null &&
            data['professionOfStaff'] != null) {
          DocumentSnapshot<Map<String, dynamic>> documentReference =
              await FirebaseFirestore.instance
                  .collection(data['professionOfStaff'])
                  .doc(doc.id)
                  .get();
          var StatffsData = documentReference.data();
          if (StatffsData?['Status'] == true) {
            double p1 = double.parse(data['lat']);
            double p2 = double.parse(data['long']);
            setState(() {
              switch (data['professionOfStaff']) {
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

  String SearchGlobal = '';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // App bar section
          Container(
            height: 150,
            color: Color(0xfffffcc9),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppBar(
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: Center(
                      child: Text("Map",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  backgroundColor: Color(0xfffffcc9),
                  automaticallyImplyLeading: false,
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 125),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Container(
                        child: LoaderCheck
                            ? Center(child: CircularProgressIndicator())
                            : FlutterMap(
                                options: MapOptions(
                                  initialZoom: 14,
                                  maxZoom: 18,
                                  minZoom: 3,
                                  center: LatLng(18.577401, 73.9774084),
                                ),
                                children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      fallbackUrl:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    ),
                                    MarkerLayer(
                                      markers:
                                          AvailableStaff.map((item) => Marker(
                                              point: item,
                                              width: 80,
                                              height: 80,
                                              child: Icon(
                                                Icons.location_history,
                                                size: 30,
                                                color: Colors.red,
                                              ))).toList(),
                                    ),

                                    // New data

                                    // Chef
                                    MarkerLayer(
                                      markers: chefmarker
                                          .map(
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
                                          )
                                          .toList(),
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
                                            color: const Color.fromARGB(
                                                255, 3, 94, 230),
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
                                            color: const Color.fromRGBO(
                                                240, 181, 177, 1),
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
                                            color: const Color.fromARGB(
                                                255, 234, 132, 132),
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
                                            color: const Color.fromARGB(
                                                183, 226, 43, 30),
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
                                            color: const Color.fromARGB(
                                                255, 2, 242, 10),
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
                                            color: const Color.fromARGB(
                                                255, 3, 86, 153),
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
                                            color: const Color.fromARGB(
                                                255, 119, 2, 41),
                                            size: 30.0,
                                          ),
                                        ),
                                      ).toList(),
                                    ),
                                    MarkerLayer(
                                      markers:
                                          AdministrativeAssistantsMarker.map(
                                        (point) => Marker(
                                          point: point,
                                          width: 80.0,
                                          height: 80.0,
                                          child: Icon(
                                            Icons.person_pin,
                                            color: const Color.fromARGB(
                                                255, 25, 0, 29),
                                            size: 30.0,
                                          ),
                                        ),
                                      ).toList(),
                                    ),
                                  ]),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            children: [
                              Container(
                                width: screenWidth * 0.7,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        spreadRadius: 1,
                                        color: Colors.black26,
                                        blurRadius: 1)
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Icon(Icons.search,
                                          color: Colors.blue, size: 25),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            SearchGlobal = value;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Search...',
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Container(
                                  height: 50,
                                  width: screenWidth * 0.18,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          spreadRadius: 1,
                                          color: Colors.black26,
                                          blurRadius: 1),
                                    ],
                                  ),
                                  child: Icon(Icons.filter_list_sharp,
                                      size: 30, color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SearchGlobal == ''
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(
                        top: 180,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              height: screenHeight * 0.5,
                              width: screenWidth * 0.85,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black26,
                                        spreadRadius: 1,
                                        blurRadius: 2)
                                  ]),
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('user')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return Center(
                                      child: Text("No Users Found"),
                                    );
                                  }

                                  if (SearchGlobal.isEmpty) {
                                    return Center(child: Text("Empty"));
                                  }

                                  return ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      var data = snapshot.data!.docs[index]
                                          .data() as Map<String, dynamic>;
                                      var UID = snapshot.data!.docs[index].id;
                                      if (data['professionOfStaff'] != null &&
                                          data['First_name'] != null &&
                                          data['First_name']
                                              .toString()
                                              .toLowerCase()
                                              .startsWith(
                                                  SearchGlobal.toLowerCase())) {
                                        return Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StaffProfilePage(
                                                            StaffID: UID,
                                                            Skill: data[
                                                                'professionOfStaff']),
                                                  ));
                                            },
                                            child: Container(
                                              height: 50,
                                              width: 200,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.black26,
                                                        spreadRadius: 1,
                                                        blurRadius: 1)
                                                  ]),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Container(
                                                      height: 40,
                                                      width: 40,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(40),
                                                          image: DecorationImage(
                                                              image: NetworkImage(
                                                                  data[
                                                                      'Profile_Pic']),
                                                              fit: BoxFit
                                                                  .cover)),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Container(
                                                        width: 150,
                                                        child: Text(
                                                          "${data['First_name']} ${data['Last_name']}",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        )),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Text(
                                                      data['City'][0]
                                                              .toUpperCase() +
                                                          data['City']
                                                              .substring(1),
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      } else if (data['professionOfStaff'] !=
                                              null &&
                                          data['First_name'] != null &&
                                          data['City']
                                              .toString()
                                              .toLowerCase()
                                              .startsWith(
                                                  SearchGlobal.toLowerCase())) {
                                        return Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StaffProfilePage(
                                                            StaffID: UID,
                                                            Skill: data[
                                                                'professionOfStaff']),
                                                  ));
                                            },
                                            child: Container(
                                              height: 50,
                                              width: 200,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.black26,
                                                        spreadRadius: 1,
                                                        blurRadius: 1)
                                                  ]),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Container(
                                                      height: 40,
                                                      width: 40,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(40),
                                                          image: DecorationImage(
                                                              image: NetworkImage(
                                                                  data[
                                                                      'Profile_Pic']),
                                                              fit: BoxFit
                                                                  .cover)),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Container(
                                                        width: 150,
                                                        child: Text(
                                                          "${data['First_name']} ${data['Last_name']}",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        )),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Text(
                                                      data['City'][0]
                                                              .toUpperCase() +
                                                          data['City']
                                                              .substring(1),
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return Container();
                                    },
                                  );
                                },
                              )),
                        ],
                      ),
                    ),
            ],
          )
        ],
      ),
    );
  }
}
