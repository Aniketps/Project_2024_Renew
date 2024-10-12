import 'dart:async';

import 'package:carehub/ClientNotificationPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

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
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        LoadingText = loadingMessages[index];
        index = (index + 1) % loadingMessages.length;
      });
    });

    void _liveLocation() {
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) {
          setState(() async {
            lat = position.latitude.toString();
            long = position.longitude.toString();
            User? user = FirebaseAuth.instance.currentUser;

            await FirebaseFirestore.instance
                .collection('user')
                .doc(user?.uid)
                .update({
              'lat': lat,
              'long': long,
            });
          });
        },
      );
    };
    Loader = true;
    _liveLocation();
    _getCurrentLocation();
    Loader = false;
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
        throw
        "Location permissions are permanently denied, we cannot request.";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

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
  var total;
  bool Loader = true;
  bool DayBased = false;
  bool HourBased = true;
  bool ShareCoordinates = false;
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

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    final screenWidth = mediaquery.size.width;
    final screenHeight = mediaquery.size.height;

    int price = (HourBased
            ? (StaffData['Hour_Rate'] ?? 0)
            : (StaffData['Day_Rate'] ?? 0)) *
        count;
    double tax = (price * 15) / 100;
    var total = price + (StaffData['Traveling_Charges'] ?? 0) + tax;
    String Place = Home? 'Home' : 'Office';

// Format start time and date
    String WorkTime = (pickedTime != null)
        ? "${pickedTime!.hourOfPeriod == 0 ? 12 : pickedTime!.hourOfPeriod}:${pickedTime!.minute.toString().padLeft(2, '0')} ${pickedTime!.period == DayPeriod.am ? 'AM' : 'PM'}"
        : '--:--';

    String WorkDate = (pickedDate != null)
        ? "${pickedDate!.day}/${pickedDate!.month}/${pickedDate!.year}"
        : '--/--/----';

// Calculate End Time and Date based on HourBased or DayBased
    DateTime endDateTime;

    if (HourBased) {
      // Ensure pickedDate and pickedTime are not null
      if (pickedDate != null && pickedTime != null) {
        int hoursToAdd =
            int.tryParse(hours.text) ?? count; // Use count as a fallback;
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
        int hoursToAdd =
            int.tryParse(hours.text) ?? count; // Use count as a fallback;
        DateTime startDateTime = DateTime(
          pickedDate!.year,
          pickedDate!.month,
          pickedDate!.day,
          pickedTime!.hour,
          pickedTime!.minute,
        );
        int shift = int.parse(StaffData['Day_Shift'].toString());
        endDateTime = startDateTime.add(Duration(hours: hoursToAdd * shift));
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
        appBar: AppBar(
          title: Text("Booking and Payment"),
          backgroundColor: Colors.blue,
        ),
        body: lat==''? Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(LoadingText, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),),
                )
              ],
            )) : Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  //Information
                  Padding(
                    padding: const EdgeInsets.only(top: 3, right: 10, left: 10),
                    child: Container(
                      width: screenWidth * 0.95,
                      height: screenHeight * 0.3,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                spreadRadius: 1,
                                blurRadius: 1)
                          ]),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              StaffData['Profile_Pic']),
                                          fit: BoxFit
                                              .cover, // Adjust the fit if necessary
                                        ),
                                        borderRadius: BorderRadius.circular(80),
                                        color: Colors.orange,
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          width: 120,
                                          child: Text(
                                            "${StaffData['First_name']} ${StaffData['Last_name']}",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Text(
                                          StaffData["Status"]
                                              ? "Available"
                                              : "Busy",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.green,
                                          )),
                                      Text(
                                          "Current time is ${TimeOfDay.now().hour}:${TimeOfDay.now().minute}",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.blue,
                                          )),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 60,
                                  width: 110,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 1,
                                            spreadRadius: 1)
                                      ]),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text(
                                          StaffData["professionOfStaff"],
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text(
                                        StaffData["City"],
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      HourBased = true;
                                      DayBased = false;
                                    });
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                        ),
                                        color: HourBased
                                            ? Colors.blue
                                            : Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            spreadRadius: 1,
                                            blurRadius: 1,
                                          )
                                        ]),
                                    child: Center(
                                        child: Text(
                                      "Hour",
                                      style: TextStyle(
                                          color: HourBased
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      DayBased = true;
                                      HourBased = false;
                                    });
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                        color: DayBased
                                            ? Colors.blue
                                            : Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            spreadRadius: 1,
                                            blurRadius: 1,
                                          )
                                        ]),
                                    child: Center(
                                        child: Text(
                                      "Day",
                                      style: TextStyle(
                                          color: DayBased
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 50, right: 10, top: 5),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    children: [
                                      Container(
                                          width: screenWidth * 0.38,
                                          child: Text(
                                            HourBased ? "Hour" : "Day",
                                            style: TextStyle(
                                              fontSize: 10,
                                            ),
                                          )),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.05),
                                        child: Container(
                                          height: 20,
                                          width: screenWidth * 0.16,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 1,
                                                    spreadRadius: 1)
                                              ]),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (count != 1) {
                                                      count -= 1;
                                                    }
                                                  });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 1, left: 1),
                                                  child: Icon(
                                                    CupertinoIcons.minus,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 2, left: 2),
                                                child: Text(
                                                  "${count}",
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (count < 12) {
                                                      count += 1;
                                                    }
                                                  });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 1, left: 1),
                                                  child: Icon(
                                                    CupertinoIcons.plus,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                          child: Text(
                                        " ${price}₹",
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    children: [
                                      Container(
                                          width: screenWidth * 0.6,
                                          child: Text(
                                            "Traveling Charges",
                                            style: TextStyle(
                                              fontSize: 10,
                                            ),
                                          )),
                                      Text(
                                        "${(StaffData['Traveling_Charges'] != null) ? StaffData['Traveling_Charges'].toString() : '0'} ₹",
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    children: [
                                      Container(
                                          width: screenWidth * 0.6,
                                          child: Text(
                                            "Platform charges 15%",
                                            style: TextStyle(
                                              fontSize: 10,
                                            ),
                                          )),
                                      Text(
                                        "${tax} ₹",
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 30),
                                  child: Divider(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    children: [
                                      Container(
                                          width: screenWidth * 0.2,
                                          child: Text(
                                            "Total",
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Container(
                                          width: screenWidth * 0.4,
                                          child: Text(
                                            "Know More",
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Text(
                                        "${total} ₹",
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
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
                    padding: const EdgeInsets.only(top: 5, right: 10, left: 10),
                    child: Container(
                      width: screenWidth * 0.95,
                      height: screenHeight * 0.2,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                spreadRadius: 1,
                                blurRadius: 1)
                          ]),
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          children: [
                            Container(
                              width: screenWidth * 0.9,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: screenWidth * 0.4,
                                    height: 60,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Schedule",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: screenWidth * 0.2,
                                    height: 60,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Know more",
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Container(
                                      width: (screenWidth * 0.3) - 2,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              spreadRadius: 1,
                                              blurRadius: 1,
                                            )
                                          ]),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          "GUERANTEE ON TIME",
                                          style: TextStyle(fontSize: 10),
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
                                    width: screenWidth * 0.23,
                                    height: 30,
                                    child: InkWell(
                                        onTap: () async {
                                          DateTime? selectedDate =
                                              await showDatePicker(
                                            context: context,
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime.now()
                                                .add(Duration(days: 12)),
                                            initialDate: DateTime.now(),
                                          );
                                          if (selectedDate != null) {
                                            setState(() {
                                              pickedDate = selectedDate;
                                            });
                                          }
                                        },
                                        child: Text(
                                          "Select Date",
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.blue),
                                        )),
                                  ),
                                  Container(
                                    width: screenWidth * 0.23,
                                    height: 30,
                                    child: InkWell(
                                        onTap: () async {
                                          TimeOfDay? selectedTime =
                                              await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now(),
                                          );
                                          if (selectedTime != null) {
                                            setState(() {
                                              pickedTime = selectedTime;
                                            });
                                          }
                                        },
                                        child: Text(
                                          "Select Time",
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.blue),
                                        )),
                                  ),
                                  Container(
                                    width: screenWidth * 0.24,
                                    height: 30,
                                    child: Text(
                                      WorkDate,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Container(
                                    width: (screenWidth * 0.2) - 2,
                                    height: 30,
                                    child: Text(
                                      pickedTime != null ? WorkTime : '--:--',
                                      style: TextStyle(fontSize: 12),
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
                                    width: screenWidth * 0.15,
                                    height: 30,
                                    child: Text(
                                      "Due to",
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: screenWidth * 0.31,
                                    height: 30,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          EnterAddress = true;
                                        });
                                      },
                                      child: Text(
                                        (City.text.isEmpty && Address.text.isEmpty)? "Select Address" : "Change Address",
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.blue),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: screenWidth * 0.24,
                                    height: 30,
                                    child: Text(
                                      pickedDate != null
                                          // Adding 12 days to the pickedDate and displaying day, month, and year
                                          ? WorkDateEnd
                                          : "--/--/----",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Container(
                                    width: (screenWidth * 0.2) - 2,
                                    height: 30,
                                    child: Text(
                                      WorkTimeEnd,
                                      style: TextStyle(fontSize: 12),
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

                  // Payment
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, right: 10, left: 10),
                    child: Container(
                      width: screenWidth * 0.95,
                      height: screenHeight * 0.4,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                spreadRadius: 1,
                                blurRadius: 1)
                          ]),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 15, left: 15),
                            child: Row(
                              children: [
                                Text(
                                  "Payment Options",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Divider(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Row(
                              children: [
                                Text(
                                  "Most Preferred",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black26,
                                        spreadRadius: 1,
                                        blurRadius: 1)
                                  ]),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTo4x8kSTmPUq4PFzl4HNT0gObFuEhivHOFYg&s|"))),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: Container(
                                              width: screenWidth * 0.7,
                                              child: Text("PhonePe UPI")),
                                        ),
                                        Container(
                                          height: 7,
                                          width: 7,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              color: Colors.blue),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: InkWell(
                                      onTap: () {
                                        var UID = FirebaseAuth
                                            .instance.currentUser?.uid;
                                        String city = City.text;
                                        String address = Address.text;
                                        String subAddress = SubAddress.text;
                                        String place = Place;

                                        if (price != 0 && WorkDate != '--/--/----' && WorkTime != '--:--' && city.isNotEmpty && address.isNotEmpty && subAddress.isNotEmpty && place.isNotEmpty) {
                                          try{
                                            FirebaseFirestore.instance
                                                .collection(
                                                    'NotificationForStaff')
                                                .add({
                                              'userUID': UID,
                                              'Scheduled_City': city,
                                              'Scheduled_Address': address,
                                              'Scheduled_Sub_Address':
                                                  subAddress,
                                              'Scheduled_Place': place,
                                              "Client_Coordinates_lat":
                                                  ShareCoordinates ? lat : "",
                                              "Client_Coordinates_long":
                                                  ShareCoordinates ? long : "",
                                              'staffUID': StaffID,
                                              'professionOfStaff': Skill,
                                              'status': 'Received a Request',
                                              'timeofdeal':
                                                  "${DateTime.now().day} ${DateFormat.MMM().format(DateTime.now())} ${DateTime.now().year} ${DateFormat.jm().format(DateTime.now())}",
                                              'totalcost': total,
                                              'ServiceBase':
                                                  HourBased ? 'Hour' : 'Day',
                                              'hours': "${count}",
                                              'ScheduledDate': WorkDate,
                                              'ScheduledTime': WorkTime,
                                              'PlatformTax': '15%',
                                              'ScheduledDateEnd': WorkDateEnd,
                                              'ScheduledTimeEnd': WorkTimeEnd,
                                            }).then((staffDocRef) {
                                              String staffDocUID =
                                                  staffDocRef.id;

                                              FirebaseFirestore.instance
                                                  .collection(
                                                      'NotificationForUser')
                                                  .add({
                                                'userUID': UID,
                                                'staffUID': StaffID,
                                                'status': 'Request sent',
                                                'Scheduled_City': city,
                                                'Scheduled_Address': address,
                                                'Scheduled_Sub_Address':
                                                    subAddress,
                                                'Scheduled_Place': place,
                                                "Client_Coordinates_lat":
                                                    ShareCoordinates ? lat : "",
                                                "Client_Coordinates_long":
                                                    ShareCoordinates
                                                        ? long
                                                        : "",
                                                'professionOfStaff': Skill,
                                                'timeofdeal':
                                                    "${DateTime.now().day} ${DateFormat.MMM().format(DateTime.now())} ${DateTime.now().year} ${DateFormat.jm().format(DateTime.now())}",
                                                'DocUID': staffDocUID,
                                                'totalcost': total,
                                                'ServiceBase':
                                                    HourBased ? 'Hour' : 'Day',
                                                'hours': "${count}",
                                                'ScheduledDate': WorkDate,
                                                'ScheduledTime': WorkTime,
                                                'PlatformTax': '15%',
                                                'ScheduledDateEnd': WorkDateEnd,
                                                'ScheduledTimeEnd': WorkTimeEnd,
                                              }).then((userDocRef) {
                                                String userDocUID =
                                                    userDocRef.id;
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        'NotificationForStaff')
                                                    .doc(staffDocUID)
                                                    .update({
                                                  'DocUID': userDocUID,
                                                });
                                              }).catchError((error) {
                                                print(
                                                    "Error adding document to NotificationForUser: $error");
                                              });
                                            }).catchError((error) {
                                              print(
                                                  "Error adding document to NotificationForStaff: $error");
                                            });

                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ClientNotificationPage(),
                                              ));
                                          }catch (e){
                                            Fluttertoast.showToast(
                                                msg: "${e}",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM
                                            );
                                          }
                                        } else {

                                          if(price == 0) {
                                            Fluttertoast.showToast(
                                                msg: "User did not set service rate",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM
                                            );
                                          }else if(WorkDate == '--/--/----'){
                                            Fluttertoast.showToast(
                                                msg: "Invalid Date",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM
                                            );
                                          }else if(WorkTime == '--:--'){
                                            Fluttertoast.showToast(
                                                msg: "Invalid Time",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM
                                            );
                                          }else if(city.isEmpty){
                                            Fluttertoast.showToast(
                                                msg: "Invalid City",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM
                                            );
                                          }else if(address.isEmpty){
                                            Fluttertoast.showToast(
                                                msg: "Invalid Address",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM
                                            );
                                          }else if(subAddress.isEmpty){
                                            Fluttertoast.showToast(
                                                msg: "Invalid Sub Address",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM
                                            );
                                          }else{
                                            Fluttertoast.showToast(
                                                msg: "Invalid Place",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM
                                            );
                                          }
                                        }
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 180,
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black26,
                                                  spreadRadius: 1,
                                                  blurRadius: 1)
                                            ]),
                                        child: Center(
                                            child: Text(
                                          "Pay 145",
                                          style: TextStyle(color: Colors.white),
                                        )),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 15, top: 10),
                            child: Row(
                              children: [
                                Text(
                                  "UPI",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black26,
                                        spreadRadius: 1,
                                        blurRadius: 1)
                                  ]),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      "https://cdn.iconscout.com/icon/free/png-256/free-google-pay-logo-icon-download-in-svg-png-gif-file-formats--gpay-payment-money-pack-logos-icons-1721670.png"))),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: Container(
                                              width: screenWidth * 0.7,
                                              child: Text("GPay UIP")),
                                        ),
                                        Container(
                                          height: 7,
                                          width: 7,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              color: Colors.green),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      "https://cdn.icon-icons.com/icons2/730/PNG/512/paytm_icon-icons.com_62778.png"))),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: Container(
                                              width: screenWidth * 0.7,
                                              child: Text("Paytm UPI")),
                                        ),
                                        Container(
                                          height: 7,
                                          width: 7,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              color: Colors.green),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      "https://img.icons8.com/color/200/bhim.png"))),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: Container(
                                              width: screenWidth * 0.7,
                                              child:
                                                  Text("Pay by any UPI App")),
                                        ),
                                        Container(
                                          height: 7,
                                          width: 7,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              color: Colors.green),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            EnterAddress
                ? Center(
                    child: Container(
                      height: screenHeight * 0.5,
                      width: screenWidth * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 5, left: 20, right: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Your Location",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      EnterAddress = false;
                                    });
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 1,
                                              spreadRadius: 1)
                                        ]),
                                    child: Icon(Icons.close_fullscreen),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10, left: 10),
                            child: Divider(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              height: 50,
                              child: TextField(
                                controller: City,
                                decoration: InputDecoration(
                                    labelText: "City", // Placeholder text
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20,
                                        16,
                                        16,
                                        16) // Adds border around the text field
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 10, left: 10, top: 5),
                            child: Container(
                              height: 45,
                              child: TextField(
                                controller: SubAddress,
                                decoration: InputDecoration(
                                    labelText:
                                        "Building/House/Flat/Floor no", // Placeholder text
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20,
                                        16,
                                        16,
                                        16) // Adds border around the text field
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 10, left: 10, top: 10),
                            child: Container(
                              height: 45,
                              child: TextField(
                                controller: Address,
                                decoration: InputDecoration(
                                    labelText: "Address", // Placeholder text
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(
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
                                padding: const EdgeInsets.only(
                                    right: 5, left: 10, top: 5),
                                child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        Home = !Home;
                                        Office = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Home
                                            ? Colors.blue
                                            : Colors.white,
                                    ),
                                    child: Text("Home",style: TextStyle(color: Home? Colors.white : Colors.blue),)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 10, left: 5, top: 5),
                                child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        Office = !Office;
                                        Home = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Office
                                          ? Colors.blue
                                          : Colors.white,
                                    ),
                                    child: Text("Office",style: TextStyle(color: Office? Colors.white : Colors.blue),)),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 10, left: 10, top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Share Current Location",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      ShareCoordinates = !ShareCoordinates;
                                    });
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: ShareCoordinates? Colors.green : Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.redAccent,
                                            spreadRadius: 1,
                                            blurRadius: 1)
                                      ],
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Icon(Icons.my_location),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  EnterAddress = false;
                                });
                              },
                              child: Container(
                                height: 45,
                                width: screenWidth * 0.65,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.green,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 1,
                                          spreadRadius: 1)
                                    ]),
                                child: Center(
                                    child: Text(
                                  "Save Address",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
          ],
        ));
  }
}
