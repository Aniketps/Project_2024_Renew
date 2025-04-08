import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'LoaderSupport.dart';
import 'StaffProfilePage.dart';

class MainMap extends StatefulWidget {
  final String whichStaff;
  const MainMap({super.key, required this.whichStaff});

  @override
  State<MainMap> createState() => _MainMapState(whichStaff: whichStaff);
}

class StaffLocation {
  final LatLng location;
  final String staffID;
  final String skill;
  final String Profile_Pic;

  StaffLocation(
      {required this.location,
      required this.staffID,
      required this.skill,
      required this.Profile_Pic});
}

class _MainMapState extends State<MainMap> {
  final String whichStaff;
  _MainMapState({required this.whichStaff});
  List<StaffLocation> AvailableStaff = [];

  List<StaffLocation> RegisteredNurseMarker = [];
  List<StaffLocation> LicensdePracticalNurseMarker = [];
  List<StaffLocation> CertifiedNursAssistentMarker = [];
  List<StaffLocation> HomeHealthAidesMarker = [];
  List<StaffLocation> PhysiotherapistsMarker = [];
  List<StaffLocation> OccupationalTherapistsMarker = [];
  List<StaffLocation> ParamedicsMarker = [];
  List<StaffLocation> DisabledCaregiversMarker = [];
  List<StaffLocation> CooksMarker = [];
  List<StaffLocation> HousekeepersMarker = [];
  List<StaffLocation> CleaningStaffMarker = [];
  List<StaffLocation> BabysittersMarker = [];
  List<StaffLocation> ElderCompanionsMarker = [];
  List<StaffLocation> HomeGuardsMarker = [];
  List<StaffLocation> SecurityGuardsMarker = [];
  List<StaffLocation> PersonalCareAssistantsMarker = [];
  List<StaffLocation> DriverMarker = [];
  List<StaffLocation> AdministrativeAssistantsMarker = [];
  List<StaffLocation> chefmarker = [];

  late double lat;
  late double long;
  String locationMessage = "Check current location";
  bool LoaderCheck = false;
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
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
    UserCurrentLatLong();
  }

  late MapController _mapController;

  double searchedlat = 0.0;
  double searchedlong = 0.0;
  Timer? _debounce;

  Future<void> getCoordinatesFromName(String placeName) async {
    try {
      List<Location> locations = await locationFromAddress(placeName);
      if (locations.isNotEmpty) {
        setState(() {
          searchedlat = locations.first.latitude;
          searchedlong = locations.first.longitude;
        });

        // Move the map to new location
        _mapController.move(LatLng(searchedlat, searchedlong), 14.0);
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  late double currentUserlat;
  late double currentUserlong;
  bool isLoading = true;

  void UserCurrentLatLong() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot data = await FirebaseFirestore.instance
            .collection("user")
            .doc(user.uid)
            .get();

        if (data.exists) {
          setState(() {
            currentUserlat = double.tryParse(data['lat'].toString()) ?? 0.0;
            currentUserlong = double.tryParse(data['long'].toString()) ?? 0.0;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print("Document does not exist");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching user location: $e");
    }
  }

  Future<void> getStaffLocation() async {
    Stream<QuerySnapshot<Map<String, dynamic>>> querySnapshot =
        FirebaseFirestore.instance.collection("user").snapshots();

    querySnapshot.listen((snapshot) async {
      for (var doc in snapshot.docs) {
        var data = doc.data();
        Future<void> getStaffLocationData() async {
          try {
            // Safely get 'professionOfStaff', falling back to an empty string if null
            String professionOfStaff = data['professionOfStaff'] ?? '';

            // Ensure 'lat' and 'long' are not null, and handle if they are.
            double? lat = double.tryParse(data['lat'] ?? '');
            double? long = double.tryParse(data['long'] ?? '');

            if (lat != null && long != null) {
              DocumentSnapshot<Map<String, dynamic>> documentReference =
                  await FirebaseFirestore.instance
                  .collection(professionOfStaff)
                  .doc(doc.id)
                  .get();

              var StatffsData = documentReference.data();

              DateTime now = DateTime.now();
              if(data.containsKey("expire") && (data["expire"] as Timestamp).toDate().isAfter(now)){
                if (StatffsData?['Status'] == true) {
                  String StaffID = doc.id;
                  print("The uid is : $StaffID");
                  String Skill = professionOfStaff;

                  setState(() {
                    StaffLocation staffLocation = StaffLocation(
                      location: LatLng(lat, long),
                      staffID: StaffID,
                      skill: Skill,
                      Profile_Pic: StatffsData?['Profile_Pic'] ??
                          "https://img.pikbest.com/png-images/qiantu/cute-cartoon-male-company-employee-happy-smiling-face-1_2659207.png!sw800",
                    );

                    // Add to corresponding markers list based on profession
                    switch (professionOfStaff) {
                      case 'chef':
                        chefmarker.add(staffLocation);
                        break;
                      case 'personal Care Assistants':
                        PersonalCareAssistantsMarker.add(staffLocation);
                        break;
                      case 'driver':
                        DriverMarker.add(staffLocation);
                        break;
                      case 'security Guards':
                        SecurityGuardsMarker.add(staffLocation);
                        break;
                      case 'home Guards':
                        HomeGuardsMarker.add(staffLocation);
                        break;
                      case 'elder Companions':
                        ElderCompanionsMarker.add(staffLocation);
                        break;
                      case 'babysitters':
                        BabysittersMarker.add(staffLocation);
                        break;
                      case 'cleaner':
                        CleaningStaffMarker.add(staffLocation);
                        break;
                      case 'housekeepers':
                        HousekeepersMarker.add(staffLocation);
                        break;
                      case 'elderly':
                        ElderCompanionsMarker.add(staffLocation);
                        break;
                      case 'paramedics':
                        ParamedicsMarker.add(staffLocation);
                        break;
                      case 'occupational Therapists':
                        OccupationalTherapistsMarker.add(staffLocation);
                        break;
                      case 'physiotherapists':
                        PhysiotherapistsMarker.add(staffLocation);
                        break;
                      case 'home Health Aides':
                        HomeHealthAidesMarker.add(staffLocation);
                        break;
                      case 'certified Nursing Assistants':
                        CertifiedNursAssistentMarker.add(staffLocation);
                        break;
                      case 'licensed Practical Nurses':
                        LicensdePracticalNurseMarker.add(staffLocation);
                        break;
                      case 'registered Nurses':
                        RegisteredNurseMarker.add(staffLocation);
                        break;
                    }

                    AvailableStaff.add(staffLocation);
                  });
                }
              }
            }
          } catch (e) {
            print('Error fetching document for ${doc.id}: $e');
          }
        }
        if (data['lat'] != null &&
            data['long'] != null &&
            data['professionOfStaff'] != null &&
            data['Verified'] == 'verified') {
          if(whichStaff.toLowerCase() != "all"){
            if(data['professionOfStaff'] == whichStaff.toLowerCase()){
              getStaffLocationData();
            }
          }
          else
          {
            getStaffLocationData();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Cancel debounce when widget is removed
    super.dispose();
  }
  List<String> items = [
    "Chef",
    "Personal Care Assistants",
    "Driver",
    "Security Guards",
    "Home Guards",
    "Elder Companions",
    "Babysitters",
    "Cleaner",
    "Housekeepers",
    "Elderly",
    "Paramedics",
    "Occupational Therapists",
    "Physiotherapists",
    "Home Health Aides",
    "Certified Nursing Assistants",
    "Licensed Practical Nurses",
    "Registered Nurses"
  ];

  Widget createMarkerLayer(List<StaffLocation> markerData, Color color) {
    return MarkerLayer(
      markers: markerData
          .map(
            (staffLocation) => Marker(
              point: staffLocation.location,
              width: 40.0,
              height: 40.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StaffProfilePage(
                        StaffID: staffLocation.staffID,
                        Skill: staffLocation.skill,
                      ),
                    ),
                  );
                },
                child: Container(
                  child: CircleAvatar(
                    radius: 15.0,
                    backgroundImage: NetworkImage(staffLocation.Profile_Pic),
                    backgroundColor: color,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

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
          isLoading
              ? Center(child: LoaderSupport.loadingAnimation.widget)
              : Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 125),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 25),
                            child: Container(
                              child: LoaderCheck
                                  ? Center(child: LoaderSupport.loadingAnimation.widget)
                                  : FlutterMap(
                                      mapController: _mapController,
                                      options: MapOptions(
                                        initialZoom: 14,
                                        maxZoom: 18,
                                        minZoom: 3,
                                        center: (searchedlat == 0.0 &&
                                                searchedlong == 0.0)
                                            ? LatLng(
                                                currentUserlat, currentUserlong)
                                            : LatLng(searchedlat, searchedlong),
                                      ),
                                      children: [
                                          TileLayer(
                                            urlTemplate: 'https://mt.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                                          ),
                                          MarkerLayer(
                                            markers: AvailableStaff.map(
                                                (item) => Marker(
                                                    point: item.location,
                                                    width: 80,
                                                    height: 80,
                                                    child: Icon(
                                                      Icons.location_history,
                                                      size: 30,
                                                      color: Colors.red,
                                                    ))).toList(),
                                          ),

                                          // Current User Location
                                          MarkerLayer(
                                            markers: [
                                              Marker(
                                                point: LatLng(currentUserlat,
                                                    currentUserlong), // Corrected point format
                                                width: 80.0,
                                                height: 80.0,
                                                child: Icon(
                                                  Icons.location_history_sharp,
                                                  color: Colors.green,
                                                  size: 30.0,
                                                ),
                                              ),
                                            ],
                                          ),

                                          // New data
                                          // Usage of the function for different staff
                                          createMarkerLayer(
                                              chefmarker, Colors.yellow),
                                          createMarkerLayer(
                                              LicensdePracticalNurseMarker,
                                              Color.fromARGB(255, 3, 94, 230)),
                                          createMarkerLayer(
                                              CertifiedNursAssistentMarker,
                                              Colors.purple),
                                          createMarkerLayer(
                                              HomeHealthAidesMarker,
                                              Colors.blue),
                                          createMarkerLayer(
                                              PhysiotherapistsMarker,
                                              Colors.black),
                                          createMarkerLayer(
                                              OccupationalTherapistsMarker,
                                              Colors.green),
                                          createMarkerLayer(
                                              ParamedicsMarker, Colors.brown),
                                          createMarkerLayer(
                                              DisabledCaregiversMarker,
                                              Colors.pink),
                                          createMarkerLayer(CooksMarker,
                                              Color.fromRGBO(240, 181, 177, 1)),
                                          createMarkerLayer(
                                              HousekeepersMarker,
                                              Color.fromARGB(
                                                  255, 234, 132, 132)),
                                          createMarkerLayer(CleaningStaffMarker,
                                              Color.fromARGB(183, 226, 43, 30)),
                                          createMarkerLayer(BabysittersMarker,
                                              Color.fromARGB(255, 2, 242, 10)),
                                          createMarkerLayer(
                                              ElderCompanionsMarker,
                                              Color.fromARGB(255, 3, 86, 153)),
                                          createMarkerLayer(
                                              HomeGuardsMarker, Colors.red),
                                          createMarkerLayer(
                                              SecurityGuardsMarker,
                                              Colors.blueGrey),
                                          createMarkerLayer(
                                              PersonalCareAssistantsMarker,
                                              Colors.white),
                                          createMarkerLayer(DriverMarker,
                                              Color.fromARGB(255, 119, 2, 41)),
                                          createMarkerLayer(
                                              AdministrativeAssistantsMarker,
                                              Color.fromARGB(255, 25, 0, 29)),
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
                                      width: screenWidth * 0.88,
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
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Icon(Icons.search,
                                                color: Colors.blue, size: 25),
                                          ),
                                          Expanded(
                                            child: TextField(
                                              onChanged: (value) {
                                                if (_debounce?.isActive ??
                                                    false) _debounce!.cancel();
                                                _debounce = Timer(
                                                    Duration(milliseconds: 500),
                                                    () {
                                                  getCoordinatesFromName(value);
                                                });
                                              },
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: 'Search...',
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top : 45.0),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  border: Border.all(width: 1, color: Colors.blueAccent)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8),
                                  child: DropdownButton<String>(
                                    underline: null,
                                    borderRadius: BorderRadius.circular(15),
                                    value: selectedValue,
                                    hint: Text("$whichStaff Profession", style: GoogleFonts.sanchez(fontWeight: FontWeight.bold),),
                                    items: items.map((String item) {
                                      return DropdownMenuItem<String>(
                                        value: item,
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth: 150,
                                          ),
                                          child: Text(
                                            item,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1, // Limit to 1 line
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      String profession = newValue!;
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainMap(whichStaff: newValue),));
                                    },
                                  ),
                                ),
                              ),
                            ),
                          )
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
