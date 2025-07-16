import 'dart:async';
import 'package:carehub/ClientNotificationPage.dart';
import 'package:carehub/services/convertToTranslate.dart';
import 'package:carehub/services/sendNotificationService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoaderSupport.dart';
import 'TempMap.dart';
import 'globle.dart';

class BookingScheduleAndPayment extends StatefulWidget {
  var StaffData;
  var StaffID;
  var Skill;
  BookingScheduleAndPayment(
      {required this.StaffData, required this.StaffID, required this.Skill});

  @override
  State<StatefulWidget> createState() => _BookingScheduleAndPayment(
      StaffData: StaffData, StaffID: StaffID, Skill: Skill);
}

class _BookingScheduleAndPayment extends State<BookingScheduleAndPayment> {
  String LoadingText = 'Locating';

  late LocationPermission permission;
  List<String> loadingMessages = [
    'Locating.',
    'Locating..',
    'Locating...',
  ];

  Timer? timer;
  int index = 0;
  @override
  void initState() {
    super.initState();
    contactFocusNode.addListener(() {
      if (!contactFocusNode.hasFocus) {
        _formatPhoneNumberOnBlur();
      }
    });
    Loader = true;
    _liveLocation();
    _getCurrentLocation();
    Loader = false;
    UID = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> _formatPhoneNumberOnBlur() async {
    final raw = contactController.text.trim();
    if (raw.isEmpty) return;

    try {
      // Reverse geocode to get ISO country code
      List<Placemark> placemarks = await placemarkFromCoordinates(
        double.parse(lat),
        double.parse(long),
      );

      if (placemarks.isNotEmpty) {
        String? code = placemarks.first.isoCountryCode;

        // Find matching IsoCode enum value from string
        IsoCode? isoCode = IsoCode.values.firstWhere(
              (e) => e.name.toUpperCase() == code,
          orElse: () => IsoCode.US, // fallback
        );

        // Parse and format the phone number
        final parsed = PhoneNumber.parse(
          raw,
          callerCountry: isoCode,
        );
        final formatted = parsed.international;

        contactController.text = formatted;
        contactController.selection = TextSelection.collapsed(offset: formatted.length);
      }
    } catch (e) {
      print("Invalid number format: $e");
    }
  }


  var UID = "";

  void _liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) async {
        setState(() {
          lat = position.latitude.toString();
          long = position.longitude.toString();
        });
        User? user = FirebaseAuth.instance.currentUser;
        await FirebaseFirestore.instance
            .collection('user')
            .doc(user?.uid)
            .update({
          'lat': lat,
          'long': long,
        });
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        throw "Location services are disabled.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          throw "Location permissions are denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        throw "Location permissions are permanently denied, we cannot request.";
      });
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.lowest,
      ),
    );

    setState(() {
      lat = '${position.latitude}';
      long = '${position.longitude}';
    });
  }

  var StaffData;
  var StaffID;
  var Skill;
  _BookingScheduleAndPayment(
      {required this.StaffData, required this.StaffID, required this.Skill});

  TextEditingController hours = TextEditingController();
  Future<bool> getShareLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getDouble("SelectedLat") == 0.0) {
      return false;
    } else {
      return true;
    }
  }

  var total;
  bool Loader = true;
  bool DayBased = false;
  bool HourBased = true;
  bool ShareCoordinates = true;
  int count = 1;
  DateTime? pickedDate;
  TimeOfDay? pickedTime;
  bool EnterAddress = false;
  bool Home = true;
  bool Office = false;
  String lat = '';
  String long = '';
  TextEditingController City = TextEditingController();
  TextEditingController SubAddress = TextEditingController();
  TextEditingController Address = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final FocusNode contactFocusNode = FocusNode();
  bool isAccepted = false;
  bool isAcceptOpen = false;
  bool loading = false;
  bool isManually = false;

  Map<String, bool> isSelected = {};
  bool isSelectedInitialized = false;
  int initialCount = 0;

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;

    int price = (HourBased
            ? (StaffData['Hour_Rate'] ?? 0)
            : (StaffData['Day_Rate'] ?? 0)) *
        count;
    var total = price + (StaffData['Traveling_Charges'] ?? 0);
    String Place = Home ? 'Home' : 'Office';

// Format start time and date
    String WorkTime = (pickedTime != null)
        ? "${pickedTime!.hourOfPeriod == 0 ? 12 : pickedTime!.hourOfPeriod}:${pickedTime!.minute.toString().padLeft(2, '0')} ${pickedTime!.period == DayPeriod.am ? 'AM' : 'PM'}"
        : '--:--';

    String WorkDate = (pickedDate != null)
        ? "${pickedDate!.day}/${pickedDate!.month}/${pickedDate!.year}"
        : '';

// Calculate End Time and Date based on HourBased or DayBased
    DateTime endDateTime;

    if (HourBased) {
      // Ensure pickedDate and pickedTime are not null
      if (pickedDate != null && pickedTime != null) {
        int hoursToAdd = int.tryParse(hours.text) ?? count;
        DateTime startDateTime = DateTime(
          pickedDate!.year,
          pickedDate!.month,
          pickedDate!.day,
          pickedTime!.hour,
          pickedTime!.minute,
        );
        // Calculate end time by adding hours entered by the user to the pickedTime
        endDateTime = startDateTime.add(Duration(hours: hoursToAdd));
      } else {
        // Handle case where pickedDate or pickedTime is null
        endDateTime = DateTime.now(); // Fallback to current time if null
      }
    } else {
      // For day-based, add the number of days to pickedDate
      if (pickedDate != null && pickedTime != null) {
        int hoursToAdd = int.tryParse(hours.text) ?? count;
        DateTime startDateTime = DateTime(
          pickedDate!.year,
          pickedDate!.month,
          pickedDate!.day,
          pickedTime!.hour,
          pickedTime!.minute,
        );
        int.parse(StaffData['Day_Shift'].toString());
        endDateTime = startDateTime.add(Duration(days: hoursToAdd));
      } else {
        // Handle case where pickedDate is null
        endDateTime = DateTime.now(); // Fallback to current date if null
      }
    }

// Manually format the end time in 12-hour format
    int endHour = endDateTime.hour > 12
        ? endDateTime.hour - 12
        : (endDateTime.hour == 0 ? 12 : endDateTime.hour);
    String endPeriod = endDateTime.hour >= 12 ? 'PM' : 'AM';

// Format the end date and time
    String WorkTimeEnd =
        "$endHour:${endDateTime.minute.toString().padLeft(2, '0')} $endPeriod";
    String WorkDateEnd =
        "${endDateTime.day}/${endDateTime.month}/${endDateTime.year}";

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
                  title: Center(
                    child: Text("Hiring And Payment".trKey,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                  backgroundColor: Globle.theme,
                  automaticallyImplyLeading: false,
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 150),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      lat == ''
                          ? Padding(
                              padding: const EdgeInsets.only(top: 200.0),
                              child: Center(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(top: 10.0),
                                      child: Center(
                                        child: LoaderSupport
                                            .loadingAnimation.widget,
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      LoadingText,
                                      style: GoogleFonts.audiowide(
                                        color: const Color(0xFF00FFFF), // Neon Blue
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  )
                                ],
                              )),
                            )
                          : Stack(
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    children: [
                                      //Information
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 3, right: 10, left: 10),
                                        child: Container(
                                          width: screenWidth,
                                          height: screenHeight * 0.3,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              boxShadow: [
                                                const BoxShadow(
                                                    color: Colors.black26,
                                                    spreadRadius: 1,
                                                    blurRadius: 1)
                                              ]),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Container(
                                                          height: 60,
                                                          width: 60,
                                                          decoration:
                                                              BoxDecoration(
                                                            image:
                                                                DecorationImage(
                                                              image: NetworkImage(
                                                                  StaffData[
                                                                      'Profile_Pic']),
                                                              fit: BoxFit
                                                                  .cover, // Adjust the fit if necessary
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        80),
                                                            color:
                                                                Colors.orange,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets
                                                              .all(8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                              width: 120,
                                                              child: Text(
                                                                "${StaffData['First_name']} ${StaffData['Last_name']}",
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )),
                                                          Text(
                                                              StaffData[
                                                                      "Status"]
                                                                  ? "Online".trKey
                                                                  : "Offline".trKey,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 10,
                                                                color: Colors
                                                                    .green,
                                                              )),
                                                          Text(
                                                              "${"Current time is".trKey} ${TimeOfDay.now().hourOfPeriod == 0 ? 12 : TimeOfDay.now().hourOfPeriod}:${TimeOfDay.now().minute.toString().padLeft(2, '0')} ${TimeOfDay.now().period == DayPeriod.am ? 'AM' : 'PM'}",
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 10,
                                                                color: Colors
                                                                    .blue,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 60,
                                                      width: 110,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10),
                                                          color: Colors.white,
                                                          boxShadow: [
                                                            const BoxShadow(
                                                                color: Colors
                                                                    .black26,
                                                                blurRadius: 1,
                                                                spreadRadius:
                                                                    1)
                                                          ]),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 5),
                                                            child: Container(
                                                                width: 75,
                                                              child: Text(
                                                                "${StaffData['professionOfStaff'][0].toUpperCase()}${StaffData['professionOfStaff'].substring(1)}".trKey,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .red,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            StaffData["City"],
                                                            style: const TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        left: 20.0,
                                                        right: 30),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Hire on basis of".trKey,
                                                      style: TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets
                                                              .only(left: 10),
                                                      child: Row(
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                HourBased =
                                                                    true;
                                                                DayBased =
                                                                    false;
                                                              });
                                                            },
                                                            child: Container(
                                                              height: 30,
                                                              width: 50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      color: HourBased
                                                                          ? Colors.blue
                                                                          : Colors.white,
                                                                      boxShadow: [
                                                                    const BoxShadow(
                                                                      color: Colors
                                                                          .black26,
                                                                      spreadRadius:
                                                                          1,
                                                                      blurRadius:
                                                                          1,
                                                                    )
                                                                  ]),
                                                              child: Center(
                                                                  child: Text(
                                                                "Hour".trKey,
                                                                style: TextStyle(
                                                                    color: HourBased
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                DayBased =
                                                                    true;
                                                                HourBased =
                                                                    false;
                                                              });
                                                            },
                                                            child: Container(
                                                              height: 30,
                                                              width: 50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      color: DayBased
                                                                          ? Colors.blue
                                                                          : Colors.white,
                                                                      boxShadow: [
                                                                    const BoxShadow(
                                                                      color: Colors
                                                                          .black26,
                                                                      spreadRadius:
                                                                          1,
                                                                      blurRadius:
                                                                          1,
                                                                    )
                                                                  ]),
                                                              child: Center(
                                                                  child: Text(
                                                                "Day".trKey,
                                                                style: TextStyle(
                                                                    color: DayBased
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        left: 20,
                                                        right: 20,
                                                        top: 5),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets
                                                              .all(2.0),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                              width:
                                                                  screenWidth *
                                                                      0.38,
                                                              child: Text(
                                                                HourBased
                                                                    ? "Hour".trKey
                                                                    : "Day".trKey,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize:
                                                                      12,
                                                                ),
                                                              )),
                                                          Padding(
                                                            padding: EdgeInsets.only(
                                                                right:
                                                                    screenWidth *
                                                                        0.05),
                                                            child: Container(
                                                              height: 20,
                                                              width:
                                                                  screenWidth *
                                                                      0.16,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  boxShadow: [
                                                                    const BoxShadow(
                                                                        color: Colors
                                                                            .black26,
                                                                        blurRadius:
                                                                            1,
                                                                        spreadRadius:
                                                                            1)
                                                                  ]),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  InkWell(
                                                                    onTap:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        if (count !=
                                                                            1) {
                                                                          count -=
                                                                              1;
                                                                        }
                                                                      });
                                                                    },
                                                                    child:
                                                                        const Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              1,
                                                                          left:
                                                                              1),
                                                                      child:
                                                                          Icon(
                                                                        CupertinoIcons
                                                                            .minus,
                                                                        size:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            2,
                                                                        left:
                                                                            2),
                                                                    child:
                                                                        Text(
                                                                      "${count}",
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        if (count <
                                                                            12) {
                                                                          count +=
                                                                              1;
                                                                        }
                                                                      });
                                                                    },
                                                                    child:
                                                                        const Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              1,
                                                                          left:
                                                                              1),
                                                                      child:
                                                                          Icon(
                                                                        CupertinoIcons
                                                                            .plus,
                                                                        size:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                              child: Text(
                                                            " ${price} ${StaffData['Currency'] ?? '-'}",
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          )),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets
                                                              .all(2.0),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                              width:
                                                                  screenWidth *
                                                                      0.619,
                                                              child: Text(
                                                                "Traveling Charges".trKey,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      12,
                                                                ),
                                                              )),
                                                          Text(
                                                            "${(StaffData['Traveling_Charges'] != null) ? StaffData['Traveling_Charges'].toString() : '0'} ${StaffData['Currency'] ?? '-'}",
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets
                                                              .only(
                                                              right: 30),
                                                      child: Divider(),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets
                                                              .only(
                                                              top: 2.0,
                                                              left: 2,
                                                              bottom: 2,
                                                              right: 40),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                              width:
                                                                  screenWidth *
                                                                      0.2,
                                                              child: Text(
                                                                "Total".trKey,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )),
                                                          Text(
                                                            "${total} ${StaffData['Currency'] ?? '-'}",
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Schedule
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5, right: 10, left: 10),
                                        child: Container(
                                          width: screenWidth * 0.95,
                                          height: screenHeight * 0.2,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              boxShadow: [
                                                const BoxShadow(
                                                    color: Colors.black26,
                                                    spreadRadius: 1,
                                                    blurRadius: 1)
                                              ]),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 5, right : 5),
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: screenWidth * 0.9,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width:
                                                            screenWidth * 0.6,
                                                        height: 60,
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              "Schedule".trKey,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5),
                                                        child: Container(
                                                          width:
                                                              (screenWidth *
                                                                      0.3) -
                                                                  2,
                                                          height: 50,
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              boxShadow: [
                                                                const BoxShadow(
                                                                  color: Colors
                                                                      .black26,
                                                                  spreadRadius:
                                                                      1,
                                                                  blurRadius:
                                                                      1,
                                                                )
                                                              ]),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets
                                                                    .all(5.0),
                                                            child: Text(
                                                              "GUERANTEE ON TIME".trKey,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      10),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: screenWidth * 0.9,
                                                  height: 60,
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: screenWidth *
                                                            0.23,
                                                        height: 30,
                                                        child: InkWell(
                                                            onTap: () async {
                                                              DateTime?
                                                                  selectedDate =
                                                                  await showDatePicker(
                                                                context:
                                                                    context,
                                                                firstDate:
                                                                    DateTime
                                                                        .now(),
                                                                lastDate: DateTime
                                                                        .now()
                                                                    .add(const Duration(
                                                                        days:
                                                                            12)),
                                                                initialDate:
                                                                    DateTime
                                                                        .now(),
                                                              );
                                                              if (selectedDate !=
                                                                  null) {
                                                                setState(() {
                                                                  pickedDate =
                                                                      selectedDate;
                                                                });
                                                              }
                                                            },
                                                            child: Text(
                                                              "Select Date".trKey,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12,
                                                                  color: Colors
                                                                      .blue),
                                                            )),
                                                      ),
                                                      Container(
                                                        width: screenWidth *
                                                            0.23,
                                                        height: 30,
                                                        child: InkWell(
                                                            onTap: () async {
                                                              TimeOfDay?
                                                                  selectedTime =
                                                                  await showTimePicker(
                                                                context:
                                                                    context,
                                                                initialTime:
                                                                    TimeOfDay
                                                                        .now(),
                                                              );
                                                              if (selectedTime !=
                                                                  null) {
                                                                setState(() {
                                                                  pickedTime =
                                                                      selectedTime;
                                                                });
                                                              }
                                                            },
                                                            child: Text(
                                                              "Select Time".trKey,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12,
                                                                  color: Colors
                                                                      .blue),
                                                            )),
                                                      ),
                                                      Container(
                                                        width: screenWidth *
                                                            0.24,
                                                        height: 30,
                                                        child: Text(
                                                          WorkDate,
                                                          style: const TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: (screenWidth *
                                                                0.2) -
                                                            2,
                                                        height: 30,
                                                        child: Text(
                                                          pickedTime != null
                                                              ? WorkTime
                                                              : '',
                                                          style: const TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: screenWidth * 0.9,
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: screenWidth *
                                                            0.15,
                                                        height: 30,
                                                        child: Text(
                                                          "Due to".trKey,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: screenWidth *
                                                            0.31,
                                                        height: 30,
                                                        child: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              EnterAddress =
                                                                  true;
                                                            });
                                                          },
                                                          child: Text(
                                                            (City.text.isEmpty &&
                                                                    Address
                                                                        .text
                                                                        .isEmpty)
                                                                ? "Select Address".trKey
                                                                : "Change Address".trKey,
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .blue),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: screenWidth *
                                                            0.24,
                                                        height: 30,
                                                        child: Text(
                                                          pickedDate != null
                                                              // Adding 12 days to the pickedDate and displaying day, month, and year
                                                              ? WorkDateEnd
                                                              : "",
                                                          style: const TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: (screenWidth *
                                                                0.2) -
                                                            2,
                                                        height: 30,
                                                        child: Text(
                                                          WorkTimeEnd,
                                                          style: const TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Hire
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, right: 10, left: 10),
                                        child: InkWell(
                                          onTap: () async {
                                            bool confirmed = await showHireConfirmationDialog(context);
                                            if(confirmed){
                                              setState(() {
                                                loading = true;
                                              });
                                              isAcceptOpen = false;
                                              var UID = FirebaseAuth.instance.currentUser?.uid;
                                              String city = City.text;
                                              String address = Address.text;
                                              String subAddress =
                                                  SubAddress.text;
                                              String place = Place;
                                              SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();

                                              if (price != 0 &&
                                                  WorkDate != '--/--/----' &&
                                                  WorkTime != '--:--' &&
                                                  city.isNotEmpty &&
                                                  address.isNotEmpty &&
                                                  subAddress.isNotEmpty &&
                                                  place.isNotEmpty &&
                                                  prefs.getDouble(
                                                      "SelectedLat") !=
                                                      0.0 &&
                                                  prefs.getDouble(
                                                      "SelectedLong") !=
                                                      0.0) {

                                                if ("Payment Successful" ==
                                                    "Payment Successful") {
                                                  try {
                                                    // Add data to 'NotificationForStaff' collection
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                        'NotificationForStaff')
                                                        .add({
                                                      'userUID': UID,
                                                      'Scheduled_City': city,
                                                      'Scheduled_Address':
                                                      address,
                                                      'Scheduled_Sub_Address':
                                                      subAddress,
                                                      'Scheduled_Place': place,
                                                      "Client_Coordinates_lat":
                                                      ShareCoordinates
                                                          ? prefs
                                                          .getDouble(
                                                          "SelectedLat")
                                                          .toString()
                                                          : "",
                                                      "Client_Coordinates_long":
                                                      ShareCoordinates
                                                          ? prefs
                                                          .getDouble(
                                                          "SelectedLong")
                                                          .toString()
                                                          : "",
                                                      'staffUID': StaffID,
                                                      'professionOfStaff':
                                                      Skill,
                                                      'status':
                                                      'Received a Request',
                                                      'timeofdeal':
                                                      "${DateTime.now().day} ${DateFormat.MMM().format(DateTime.now())} ${DateTime.now().year} ${DateFormat.jm().format(DateTime.now())}",
                                                      'totalcost': total,
                                                      'ServiceBase': HourBased
                                                          ? 'Hour'
                                                          : 'Day',
                                                      'hours': "${count}",
                                                      'ScheduledDate': WorkDate,
                                                      'ScheduledTime': WorkTime,
                                                      'PlatformTax': '1.5%',
                                                      'ScheduledDateEnd':
                                                      WorkDateEnd,
                                                      'clientContact' : contactController.text,
                                                      'ScheduledTimeEnd':
                                                      WorkTimeEnd,
                                                    }).then((staffDocRef) {
                                                      String staffDocUID =
                                                          staffDocRef.id;
                                                      // Add data to 'NotificationForUser' collection
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                          'NotificationForUser')
                                                          .add({
                                                        'userUID': UID,
                                                        'staffUID': StaffID,
                                                        'status':
                                                        'Request sent',
                                                        'Scheduled_City': city,
                                                        'Scheduled_Address':
                                                        address,
                                                        'Scheduled_Sub_Address':
                                                        subAddress,
                                                        'Scheduled_Place':
                                                        place,
                                                        "Client_Coordinates_lat":
                                                        ShareCoordinates
                                                            ? prefs
                                                            .getDouble(
                                                            "SelectedLat")
                                                            .toString()
                                                            : "",
                                                        "Client_Coordinates_long":
                                                        ShareCoordinates
                                                            ? prefs
                                                            .getDouble(
                                                            "SelectedLong")
                                                            .toString()
                                                            : "",
                                                        'professionOfStaff':
                                                        Skill,
                                                        'timeofdeal':
                                                        "${DateTime.now().day} ${DateFormat.MMM().format(DateTime.now())} ${DateTime.now().year} ${DateFormat.jm().format(DateTime.now())}",
                                                        'DocUID': staffDocUID,
                                                        'totalcost': total,
                                                        'ServiceBase': HourBased
                                                            ? 'Hour'
                                                            : 'Day',
                                                        'hours': "${count}",
                                                        'ScheduledDate':
                                                        WorkDate,
                                                        'ScheduledTime':
                                                        WorkTime,
                                                        'PlatformTax': '1.5%',
                                                        'ScheduledDateEnd':
                                                        WorkDateEnd,
                                                        'ScheduledTimeEnd':
                                                        WorkTimeEnd,
                                                        'clientContact' : contactController.text,
                                                      }).then((userDocRef) {
                                                        String userDocUID =
                                                            userDocRef.id;

                                                        // Update 'NotificationForStaff' with the 'DocUID' from 'NotificationForUser'
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                            'NotificationForStaff')
                                                            .doc(staffDocUID)
                                                            .update({
                                                          'DocUID': userDocUID,
                                                        });
                                                      }).catchError((error) {
                                                        setState(() {
                                                          loading = false;
                                                        });
                                                        print(
                                                            "Error adding document to NotificationForUser: $error");
                                                      });
                                                    }).catchError((error) {
                                                      setState(() {
                                                        loading = false;
                                                      });
                                                      print(
                                                          "Error adding document to NotificationForStaff: $error");
                                                    });

                                                    User? user =
                                                    await FirebaseAuth
                                                        .instance
                                                        .currentUser;
                                                    var userDoc =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("user")
                                                        .doc(user?.uid)
                                                        .get();
                                                    var staffDoc =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("user")
                                                        .doc(StaffID)
                                                        .get();
                                                    var usertoken = userDoc
                                                        .data()?['token'];
                                                    var stafftoken = staffDoc
                                                        .data()?['token'];


                                                    // Generate unique IDs for the notifications
                                                    int notificationId1 = DateTime
                                                        .now()
                                                        .millisecondsSinceEpoch; // Unique ID based on timestamp
                                                    int notificationId2 =
                                                        notificationId1 +
                                                            1; // Increment to ensure uniqueness for the second notification

                                                    // Send first notification
                                                    String uid = FirebaseAuth.instance.currentUser!.uid;

                                                    // Access document using UID
                                                    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.instance
                                                        .collection("user").doc(uid).get();

                                                    sendNotificationService
                                                        .sendNotificationUsingApi(
                                                        body:
                                                        "✅ ${StaffData['First_name']} ${StaffData['Last_name']} has been notified. They'll connect with you soon. Thanks for choosing CareNest 💙",
                                                        data: {
                                                          "screen":
                                                          "ClientNotificationPage",
                                                          "notificationId":
                                                          notificationId1
                                                              .toString(), // Include notification ID in the data if needed
                                                        },
                                                        title: "🌟 Your Request Is in Good Hands",
                                                        token: usertoken);
                                                    // Send second notification

                                                    sendNotificationService
                                                        .sendNotificationUsingApi(
                                                        body: "CareNest client ${doc['First_name']} ${doc['Last_name']} has reached out for your help. Tap to view details.",
                                                        data: {
                                                          "screen":
                                                          "StaffNotificationPage",
                                                          "notificationId":
                                                          notificationId2
                                                              .toString(),
                                                          "hire":
                                                          "true" // Include notification ID in the data if needed
                                                        },
                                                        title: "🛎️ New Job Opportunity",
                                                        token: stafftoken);
                                                    prefs.setDouble(
                                                        "SelectedLat", 0.0);
                                                    prefs.setDouble(
                                                        "SelectedLong", 0.0);

                                                    setState(() {
                                                      loading = false;
                                                    });
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                        const ClientNotificationPage(),
                                                      ),
                                                    );

                                                    Fluttertoast.showToast(
                                                        msg:
                                                        "Request has been send".trKey);
                                                  } catch (e) {
                                                    setState(() {
                                                      loading = false;
                                                    });
                                                    Fluttertoast.showToast(
                                                      msg: "$e",
                                                      toastLength:
                                                      Toast.LENGTH_SHORT,
                                                      gravity:
                                                      ToastGravity.BOTTOM,
                                                    );
                                                  }
                                                } else {
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                  Fluttertoast.showToast(
                                                      msg: "Payment Failed");
                                                }
                                              } else {
                                                setState(() {
                                                  loading = false;
                                                });
                                                // Handle validation errors
                                                if (price == 0) {
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                  Fluttertoast.showToast(
                                                    msg:
                                                    "User did not set service rate".trKey,
                                                    toastLength:
                                                    Toast.LENGTH_SHORT,
                                                    gravity:
                                                    ToastGravity.BOTTOM,
                                                  );
                                                } else if (WorkDate == '') {
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                  Fluttertoast.showToast(
                                                    msg: "Please Select Date".trKey,
                                                    toastLength:
                                                    Toast.LENGTH_SHORT,
                                                    gravity:
                                                    ToastGravity.BOTTOM,
                                                  );
                                                } else if (WorkTime ==
                                                    '--:--') {
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                  Fluttertoast.showToast(
                                                    msg: "Please Select Time".trKey,
                                                    toastLength:
                                                    Toast.LENGTH_SHORT,
                                                    gravity:
                                                    ToastGravity.BOTTOM,
                                                  );
                                                } else if (city.isEmpty) {
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                  Fluttertoast.showToast(
                                                    msg: "Please Enter Address".trKey,
                                                    toastLength:
                                                    Toast.LENGTH_SHORT,
                                                    gravity:
                                                    ToastGravity.BOTTOM,
                                                  );
                                                } else if (address.isEmpty) {
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                  Fluttertoast.showToast(
                                                    msg: "Invalid Address".trKey,
                                                    toastLength:
                                                    Toast.LENGTH_SHORT,
                                                    gravity:
                                                    ToastGravity.BOTTOM,
                                                  );
                                                } else if (subAddress.isEmpty) {
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                  Fluttertoast.showToast(
                                                    msg: "Invalid Sub Address".trKey,
                                                    toastLength:
                                                    Toast.LENGTH_SHORT,
                                                    gravity:
                                                    ToastGravity.BOTTOM,
                                                  );
                                                } else {
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                  Fluttertoast.showToast(
                                                    msg: "Invalid Place".trKey,
                                                    toastLength:
                                                    Toast.LENGTH_SHORT,
                                                    gravity:
                                                    ToastGravity.BOTTOM,
                                                  );
                                                }
                                              }
                                            }
                                          },
                                          child : Container(
                                            height: 50,
                                            width: screenWidth,
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                boxShadow: [
                                                  const BoxShadow(
                                                      color: Colors.black26,
                                                      spreadRadius: 1,
                                                      blurRadius: 1)
                                                ]),
                                            child: Center(
                                                child: Text(
                                              "Hire Now".trKey,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight:
                                                      FontWeight.bold),
                                            )),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                EnterAddress
                                    ? Center(
                                        child: Container(
                                          width: screenWidth - 16,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            boxShadow: [
                                              const BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 5,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Your Location".trKey,
                                                      style:
                                                          GoogleFonts.sanchez(
                                                              fontSize: 20),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          EnterAddress =
                                                              false;
                                                          isManually = false;
                                                        });
                                                      },
                                                      onLongPress: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      SelectDestination(),
                                                            ));
                                                      },
                                                      child: Container(
                                                        height: 30,
                                                        width: 30,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                            color:
                                                                Colors.white,
                                                            boxShadow: [
                                                              const BoxShadow(
                                                                  color: Colors
                                                                      .black26,
                                                                  blurRadius:
                                                                      1,
                                                                  spreadRadius:
                                                                      1)
                                                            ]),
                                                        child:
                                                            const Icon(Icons.close),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(
                                                        right: 10, left: 10),
                                                child: Divider(),
                                              ),
                                              isManually
                                                  ? Column(children: [
                                                Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .only(left :10, right : 10),
                                                  child: Container(
                                                    height: 50,
                                                    child: TextField(
                                                      controller: contactController,
                                                      focusNode: contactFocusNode,
                                                      keyboardType: const TextInputType.numberWithOptions(),
                                                      decoration:
                                                      InputDecoration(
                                                          labelText:
                                                          "Phone no.".trKey, // Placeholder text
                                                          border:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                            BorderRadius.circular(5),
                                                          ),
                                                          contentPadding: const EdgeInsets.fromLTRB(
                                                              20,
                                                              16,
                                                              16,
                                                              16) // Adds border around the text field
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(right :10, left : 10, top: 10),
                                                        child: Container(
                                                          height: 50,
                                                          child: TextField(
                                                            controller: City,
                                                            decoration:
                                                                InputDecoration(
                                                                    labelText:
                                                                        "City".trKey, // Placeholder text
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(5),
                                                                    ),
                                                                    contentPadding: const EdgeInsets.fromLTRB(
                                                                        20,
                                                                        16,
                                                                        16,
                                                                        16) // Adds border around the text field
                                                                    ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .only(right :10, left : 10, top: 10),
                                                        child: Container(
                                                          height: 45,
                                                          child: TextField(
                                                            controller:
                                                                SubAddress,
                                                            decoration:
                                                                InputDecoration(
                                                                    labelText:
                                                                        "Building/House/Flat/Floor no".trKey, // Placeholder text
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(5),
                                                                    ),
                                                                    contentPadding: const EdgeInsets.fromLTRB(
                                                                        20,
                                                                        16,
                                                                        16,
                                                                        16) // Adds border around the text field
                                                                    ),
                                                          ),
                                                        ),
                                                      ),
                                                Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 10,
                                                                left: 10,
                                                                top: 10),
                                                        child: Container(
                                                          height: 45,
                                                          child: TextField(
                                                            controller:
                                                                Address,
                                                            decoration:
                                                                InputDecoration(
                                                                    labelText:
                                                                        "Address".trKey, // Placeholder text
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(5),
                                                                    ),
                                                                    contentPadding: const EdgeInsets.fromLTRB(
                                                                        20,
                                                                        16,
                                                                        16,
                                                                        16) // Adds border around the text field
                                                                    ),
                                                          ),
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 5,
                                                                    left: 10,
                                                                    top: 5),
                                                            child:
                                                                ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        Home =
                                                                            !Home;
                                                                        Office =
                                                                            false;
                                                                      });
                                                                    },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor: Home
                                                                          ? Colors.blue
                                                                          : Colors.white,
                                                                    ),
                                                                    child:
                                                                        Text(
                                                                      "Home".trKey,
                                                                      style: TextStyle(
                                                                          color: Home
                                                                              ? Colors.white
                                                                              : Colors.blue),
                                                                    )),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 10,
                                                                    left: 5,
                                                                    top: 5),
                                                            child:
                                                                ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        Office =
                                                                            !Office;
                                                                        Home =
                                                                            false;
                                                                      });
                                                                    },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor: Office
                                                                          ? Colors.blue
                                                                          : Colors.white,
                                                                    ),
                                                                    child:
                                                                        Text(
                                                                      "Office".trKey,
                                                                      style: TextStyle(
                                                                          color: Office
                                                                              ? Colors.white
                                                                              : Colors.blue),
                                                                    )),
                                                          )
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 10,
                                                                left: 10,
                                                                top: 5),
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  InkWell(
                                                                    onTap:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => SelectDestination(),
                                                                            ));
                                                                      });
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          50,
                                                                      width: screenWidth -
                                                                          40,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color:
                                                                            const Color(0xff2874f0),
                                                                        borderRadius:
                                                                            BorderRadius.circular(5),
                                                                      ),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Icon(Icons.my_location,
                                                                              color: Colors.white),
                                                                          SizedBox(width: 5),
                                                                          Text("Use my current location".trKey,
                                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              )
                                                            ]),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: InkWell(
                                                          onTap: () async {
                                                            SharedPreferences
                                                                prefs =
                                                                await SharedPreferences
                                                                    .getInstance();
                                                            double? lat = prefs.getDouble("SelectedLat");
                                                            double? long = prefs.getDouble("SelectedLong");
                                                            // Save Address Information
                                                            if (City.text.isNotEmpty &&
                                                                Address.text.isNotEmpty &&
                                                                SubAddress.text.isNotEmpty &&
                                                                contactController.text.isNotEmpty &&
                                                                lat != 0.0 &&
                                                                long != 0.0) {
                                                              List<Placemark> placemarks = await placemarkFromCoordinates(lat!, long!);
                                                              if (placemarks.isNotEmpty) {
                                                                String localityName = '';
                                                                setState(() {
                                                                  localityName = "${placemarks.first.street},${placemarks.first.locality}";
                                                                });
                                                                FirebaseFirestore.instance.collection('Addresses').doc(UID).collection("UserAddresses").add({
                                                                  "placeType" : Place,
                                                                  "address" : Address.text,
                                                                  "city" : City.text,
                                                                  "subAddress" : SubAddress.text,
                                                                  "contact" : contactController.text,
                                                                  'lat' : lat,
                                                                  "long" : long,
                                                                  "localName" : localityName
                                                                });
                                                                setState(() {
                                                                  EnterAddress = false;
                                                                  isManually = false;
                                                                });
                                                                Fluttertoast.showToast(msg: "Address Saved".trKey);
                                                              }else{
                                                                FirebaseFirestore.instance.collection('Addresses').doc(UID).collection("UserAddresses").add({
                                                                  "placeType" : Place,
                                                                  "address" : Address.text,
                                                                  "city" : City.text,
                                                                  "contact" : contactController.text,
                                                                  "subAddress" : SubAddress.text,
                                                                  'lat' : lat,
                                                                  "long" : long,
                                                                  "localName" : ""
                                                                });
                                                                setState(() {
                                                                  EnterAddress = false;
                                                                  isManually = false;
                                                                });
                                                                Fluttertoast.showToast(msg: "Address Saved".trKey);
                                                              }
                                                            } else {
                                                              if(City.text.isEmpty){
                                                                Fluttertoast.showToast(msg: "Please Enter City".trKey);
                                                              }else if(Address.text.isEmpty){
                                                                Fluttertoast.showToast(msg: "Please Enter Address".trKey);
                                                              }else if(contactController.text.isEmpty){
                                                                Fluttertoast.showToast(msg: "Please Enter Phone Number".trKey);
                                                              }else if(SubAddress.text.isEmpty){
                                                                Fluttertoast.showToast(msg: "Please Enter Building/House/flat".trKey);
                                                              }else{
                                                                Fluttertoast.showToast(msg: "Please Select Location from Map".trKey);
                                                              }
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 50,
                                                            width:
                                                                screenWidth -
                                                                    40,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .green,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Center(
                                                                child: Text(
                                                              "Save Address".trKey,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      14,
                                                                  color: Colors
                                                                      .white),
                                                            )),
                                                          ),
                                                        ),
                                                      ),
                                                    ])
                                                  : InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          isManually = true;
                                                        });
                                                      },
                                                      child: Container(
                                                        height: 50,
                                                        width:
                                                            screenWidth - 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5),
                                                          boxShadow: [
                                                            const BoxShadow(
                                                              color: Colors
                                                                  .black26,
                                                              blurRadius: 2,
                                                              spreadRadius: 1,
                                                            ),
                                                          ],
                                                        ),
                                                        child: Center(
                                                            child: Text(
                                                                "New Address".trKey,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))),
                                                      ),
                                                    ),
                                              Container(
                                                height: 400,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      child: StreamBuilder<QuerySnapshot>(
                                                        stream: FirebaseFirestore
                                                            .instance
                                                            .collection("Addresses")
                                                            .doc(UID)
                                                            .collection(
                                                            "UserAddresses")
                                                            .snapshots(),
                                                        builder: (context, snapshot) {
                                                          List<Row> addressesViews = [];
                                                          if (snapshot.hasData) {
                                                            final addresses = snapshot.data?.docs.reversed.toList();
                                                            if (!isSelectedInitialized || addresses?.length != initialCount) {
                                                              // Only initialize once when data is first loaded
                                                              for (var address in addresses!) {
                                                                isSelected[address.id.toString()] = false;
                                                              }
                                                              isSelectedInitialized = true;
                                                              initialCount = addresses.length;
                                                            }
                                                            for (var address in addresses!) {
                                                              Row row = Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(top : 8.0),
                                                                    child: Container(
                                                                      width: screenWidth - 50,
                                                                      decoration:
                                                                      BoxDecoration(
                                                                        color: Colors.white,
                                                                        borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                            5),
                                                                        boxShadow: [
                                                                          const BoxShadow(
                                                                            color: Colors
                                                                                .black26,
                                                                            blurRadius: 2,
                                                                            spreadRadius: 1,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Column(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                const Icon(CupertinoIcons.location_solid, color: Colors.black, size: 20,),
                                                                                const SizedBox(width: 5,),
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text("${address["city"]?? "No City Name".trKey}", style: const TextStyle(fontWeight: FontWeight.bold),),
                                                                                    SizedBox(
                                                                                        width: screenWidth - 100,
                                                                                        child: Text("${address["subAddress"]?? ""}, ${address["localName"]?? ""}, ${address["address"]?? ""}, ${address["city"]?? ""} ")),
                                                                                    Text("${address["contact"]?? "No Contact".trKey}"),
                                                                                  ],
                                                                                )
                                                                              ],
                                                                            ),
                                                                            const Divider(),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: [
                                                                                InkWell(
                                                                                  onTap : () async {
                                                                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                                    setState(() {
                                                                                      City.text = address["city"];
                                                                                      Address.text = address["address"];
                                                                                      SubAddress.text = address["subAddress"];
                                                                                      Place = address["placeType"];
                                                                                      contactController.text = address["contact"];
                                                                                    });
                                                                                    prefs.setDouble("SelectedLat", address["lat"]);
                                                                                    prefs.setDouble("SelectedLong", address["long"]);
                                                                                    Fluttertoast.showToast(msg: "Location Selected".trKey);
                                                                                    print("Before ${isSelected[address.id]}");
                                                                                    setState(() {
                                                                                      EnterAddress = false;
                                                                                      isSelected.updateAll((_, __)=> false);
                                                                                      isSelected[address.id.toString()] = true;
                                                                                    });
                                                                                  },
                                                                                  child: Container(
                                                                                    height: 35,
                                                                                    width: 100,
                                                                                    decoration:
                                                                                    BoxDecoration(
                                                                                      color: isSelected[address.id.toString()] == true? Colors.blue : Colors.green,
                                                                                      borderRadius:
                                                                                      BorderRadius.circular(5),
                                                                                      boxShadow: [
                                                                                        const BoxShadow(
                                                                                          color: Colors
                                                                                              .black26,
                                                                                          blurRadius: 1,
                                                                                          spreadRadius: 1,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    child: Center(child: Text(isSelected[address.id.toString()] == true? "Selected " : "Select", style:const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              );
                                                              addressesViews.add(row);
                                                            }
                                                          }
                                                          return ListView(
                                                            padding: EdgeInsets.zero,
                                                            children: addressesViews,
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            )
                    ],
                  ),
                ),
              ),
            ],
          ),
          loading
              ? Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Center(child: LoaderSupport.loadingAnimation.widget),
                )
              : Container(),
        ],
      ),
    );
  }
}

Future<bool> showHireConfirmationDialog(BuildContext context) async {
  int countdown = 45;
  Timer? timer;

  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Start timer only once
          timer ??= Timer.periodic(Duration(seconds: 1), (t) {
            if (countdown > 1) {
              setState(() {
                countdown--;
              });
            } else {
              t.cancel();
              Navigator.of(context).pop(false);
            }
          });

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text('Confirm Hire'.trKey),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure?\n\n'
                      'Once the request is sent, to cancel it you will need to call the staff by youself and say, don\'t come.'.trKey,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.timer, size: 20, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      '$countdown ${'sec remaining'.trKey}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: countdown <= 5 ? Colors.red : Colors.blueGrey,
                      ),
                    ),
                  ],
                )
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueGrey,
                ),
                child: Text('Cancel'.trKey),
                onPressed: () {
                  timer?.cancel();
                  Navigator.of(context).pop(false);
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Text('Hire'.trKey, style: TextStyle(color: Colors.white),),
                onPressed: () {
                  timer?.cancel();
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
    },
  ).then((value) {
    timer?.cancel(); // Safety clean-up
    return value ?? false;
  });
}
