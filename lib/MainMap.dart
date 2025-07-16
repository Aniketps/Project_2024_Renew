import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import 'LoaderSupport.dart';
import 'StaffProfilePage.dart';
import 'globle.dart';

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

  List<StaffLocation> CleanerMarker = [];
  List<StaffLocation> GardenerMarker = [];
  List<StaffLocation> HousekeepersMarker = [];
  List<StaffLocation> PersonalCareAssistantsMarker = [];
  List<StaffLocation> ElderCompanionsMarker = [];
  List<StaffLocation> ElderlyMarker = [];
  List<StaffLocation> BabysittersMarker = [];
  List<StaffLocation> TeacherMarker = [];
  List<StaffLocation> DriverMarker = [];
  List<StaffLocation> HomeGuardsMarker = [];
  List<StaffLocation> SecurityGuardsMarker = [];
  List<StaffLocation> ChefMarker = [];
  List<StaffLocation> EventHelpersMarker = [];
  List<StaffLocation> BartenderMarker = [];
  List<StaffLocation> CertifiedNursingAssistantsMarker = [];
  List<StaffLocation> HomeHealthAidesMarker = [];
  List<StaffLocation> PhysiotherapistsMarker = [];
  List<StaffLocation> ACTechnicianMarker = [];
  List<StaffLocation> ElectricianMarker = [];
  List<StaffLocation> PlumberMarker = [];
  List<StaffLocation> CarpenterMarker = [];
  List<StaffLocation> PainterMarker = [];
  List<StaffLocation> FitnessTrainerMarker = [];
  List<StaffLocation> YogaTrainerMarker = [];
  List<StaffLocation> PhotographerMarker = [];


  late double lat;
  late double long;
  String locationMessage = "Check current location";
  bool LoaderCheck = false;
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    liveLocation();
    _mapController = MapController();
    LoaderCheck = !LoaderCheck;
    getStaffLocation();
    LoaderCheck = !LoaderCheck;
    UserCurrentLatLong();
  }
  Future<void> liveLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.lowest,
      ),
    );
        setState(() {
          lat = position.latitude;
          long = position.longitude;
        });
        User? user = FirebaseAuth.instance.currentUser;
        await FirebaseFirestore.instance
            .collection('user')
            .doc(user?.uid)
            .update({
          'lat': position.latitude.toString(),
          'long': position.longitude.toString(),
        });
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
                    switch (professionOfStaff.toLowerCase()) {
                      case 'cleaner':
                        CleanerMarker.add(staffLocation);
                        break;
                      case 'gardener':
                        GardenerMarker.add(staffLocation);
                        break;
                      case 'housekeepers':
                        HousekeepersMarker.add(staffLocation);
                        break;
                      case 'personal care assistants':
                        PersonalCareAssistantsMarker.add(staffLocation);
                        break;
                      case 'elder companions':
                        ElderCompanionsMarker.add(staffLocation);
                        break;
                      case 'elderly':
                        ElderlyMarker.add(staffLocation);
                        break;
                      case 'babysitters':
                        BabysittersMarker.add(staffLocation);
                        break;
                      case 'teacher':
                        TeacherMarker.add(staffLocation);
                        break;
                      case 'driver':
                        DriverMarker.add(staffLocation);
                        break;
                      case 'home guards':
                        HomeGuardsMarker.add(staffLocation);
                        break;
                      case 'security guards':
                        SecurityGuardsMarker.add(staffLocation);
                        break;
                      case 'chef':
                        ChefMarker.add(staffLocation);
                        break;
                      case 'event helpers':
                        EventHelpersMarker.add(staffLocation);
                        break;
                      case 'bartender':
                        BartenderMarker.add(staffLocation);
                        break;
                      case 'certified nursing assistants':
                        CertifiedNursingAssistantsMarker.add(staffLocation);
                        break;
                      case 'home health aides':
                        HomeHealthAidesMarker.add(staffLocation);
                        break;
                      case 'physiotherapists':
                        PhysiotherapistsMarker.add(staffLocation);
                        break;
                      case 'ac technician':
                        ACTechnicianMarker.add(staffLocation);
                        break;
                      case 'electrician':
                        ElectricianMarker.add(staffLocation);
                        break;
                      case 'plumber':
                        PlumberMarker.add(staffLocation);
                        break;
                      case 'carpenter':
                        CarpenterMarker.add(staffLocation);
                        break;
                      case 'painter':
                        PainterMarker.add(staffLocation);
                        break;
                      case 'fitness trainer':
                        FitnessTrainerMarker.add(staffLocation);
                        break;
                      case 'yoga trainer':
                        YogaTrainerMarker.add(staffLocation);
                        break;
                      case 'photographer':
                        PhotographerMarker.add(staffLocation);
                        break;
                      default:
                      // Optional: handle unknown professions
                        break;
                    }

                    AvailableStaff.add(staffLocation);
                  });
                }
              }
            }
          } catch (e) {
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
    "Cleaner",
    "Gardener",
    "Housekeepers",
    "Personal Care Assistants",
    "Elder Companions",
    "Elderly",
    "Babysitters",
    "Teacher",
    "Driver",
    "Home Guards",
    "Security Guards",
    "Chef",
    "Event Helpers",
    "Bartender",
    "Certified Nursing Assistants",
    "Home Health Aides",
    "Physiotherapists",
    "AC Technician",
    "Electrician",
    "Plumber",
    "Carpenter",
    "Painter",
    "Fitness Trainer",
    "Yoga Trainer",
    "Photographer",
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
                child: CircleAvatar(
                  radius: 15.0,
                  backgroundImage: NetworkImage(staffLocation.Profile_Pic),
                  backgroundColor: color,
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

    return Scaffold(
      body: Stack(
        children: [
          // App bar section
          Container(
            height: 150,
            color: Globle.theme,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppBar(
                  title: const Padding(
                    padding: EdgeInsets.only(bottom: 25),
                    child: Center(
                      child: Text("Map",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold, color : Colors.white)),
                    ),
                  ),
                  backgroundColor: Globle.theme,
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
                                    initialCenter: (searchedlat == 0.0 && searchedlong == 0.0)
                                        ? LatLng(currentUserlat, currentUserlong)
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
                                                    child: const Icon(
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
                                                child: const Icon(
                                                  Icons.my_location,
                                                  color: Colors.green,
                                                  size: 30.0,
                                                ),
                                              ),
                                            ],
                                          ),

                                          // New data
                                          // Usage of the function for different staff
                                        createMarkerLayer(CleanerMarker, Colors.yellow),
                                        createMarkerLayer(GardenerMarker, Colors.green),
                                        createMarkerLayer(HousekeepersMarker, Colors.blue),
                                        createMarkerLayer(PersonalCareAssistantsMarker, Colors.pink),
                                        createMarkerLayer(ElderCompanionsMarker, Colors.brown),
                                        createMarkerLayer(ElderlyMarker, Colors.grey),
                                        createMarkerLayer(BabysittersMarker, Colors.orange),
                                        createMarkerLayer(TeacherMarker, Colors.indigo),
                                        createMarkerLayer(DriverMarker, Colors.teal),
                                        createMarkerLayer(HomeGuardsMarker, Colors.red),
                                        createMarkerLayer(SecurityGuardsMarker, Colors.black),
                                        createMarkerLayer(ChefMarker, Colors.deepOrange),
                                        createMarkerLayer(EventHelpersMarker, Colors.cyan),
                                        createMarkerLayer(BartenderMarker, Colors.deepPurple),
                                        createMarkerLayer(CertifiedNursingAssistantsMarker, Colors.lightBlue),
                                        createMarkerLayer(HomeHealthAidesMarker, Colors.lightGreen),
                                        createMarkerLayer(PhysiotherapistsMarker, Colors.amber),
                                        createMarkerLayer(ACTechnicianMarker, Colors.blueGrey),
                                        createMarkerLayer(ElectricianMarker, Colors.lime),
                                        createMarkerLayer(PlumberMarker, Colors.cyanAccent),
                                        createMarkerLayer(CarpenterMarker, Colors.brown.shade300),
                                        createMarkerLayer(PainterMarker, Colors.purple),
                                        createMarkerLayer(FitnessTrainerMarker, Colors.redAccent),
                                        createMarkerLayer(YogaTrainerMarker, Colors.greenAccent),
                                        createMarkerLayer(PhotographerMarker, Colors.pinkAccent),
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
                                      width: screenWidth - 16,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                        boxShadow: const [
                                          BoxShadow(
                                              spreadRadius: 1,
                                              color: Colors.black26,
                                              blurRadius: 1)
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(left: 10),
                                            child: Icon(Icons.search,
                                                color: Colors.blue, size: 25),
                                          ),
                                          Expanded(
                                            child: TextField(
                                              onChanged: (value) {
                                                if (_debounce?.isActive ??
                                                    false) _debounce!.cancel();
                                                _debounce = Timer(
                                                    const Duration(milliseconds: 500),
                                                    () {
                                                  getCoordinatesFromName(value);
                                                });
                                              },
                                              decoration: const InputDecoration(
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
                                          constraints: const BoxConstraints(
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
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainMap(whichStaff: newValue!.toLowerCase()),));
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
