import 'dart:math';

import 'package:carehub/TempMap.dart';
import 'package:carehub/services/convertToTranslate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'LoaderSupport.dart';
import 'globle.dart';

class ClientNotificationPage extends StatefulWidget {
  const ClientNotificationPage({super.key});

  @override
  State<StatefulWidget> createState() => _ClientNotificationPageState();
}

class _ClientNotificationPageState extends State<ClientNotificationPage> {
  @override
  @override
  void initState() {
    super.initState();
    _startLiveLocation();
  }

  void _startLiveLocation() {
    final locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) async {
        final String lat = position.latitude.toString();
        final String long = position.longitude.toString();
        final User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('user')
              .doc(user.uid)
              .update({
            'lat': lat,
            'long': long,
          });
        }

        // Optional: update local state for UI
        setState(() {
          // Update variables to show on screen if needed
          _lastKnownLat = lat;
          _lastKnownLong = long;
        });
      },
    );
  }

// Define these variables in your state if you want to display them
  String? _lastKnownLat;
  String? _lastKnownLong;


  User? currentUser = FirebaseAuth.instance.currentUser;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    var snapshot =
        await FirebaseFirestore.instance.collection("user").doc(uid).get();
    return snapshot.data();
  }

  Future<Map<String, dynamic>?> getStaffData(String skill, String uid) async {
    var snapshot =
        await FirebaseFirestore.instance.collection(skill).doc(uid).get();
    return snapshot.data();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Stack(
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
                      child: Text("Notifications".trKey,
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
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("NotificationForUser")
                                .snapshots(),
                            builder: (context, snapshot) {

                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Padding(
                                  padding: const EdgeInsets.only(top : 200.0),
                                  child: Center(child: LoaderSupport.loadingAnimation.widget),
                                );
                              }
                              else if (snapshot.hasError) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 200.0),
                                  child: Center(
                                      child: Text(
                                        "Failed to get Notifications, Please try again".trKey,
                                        style: TextStyle(fontSize: 16),
                                      )),
                                );
                              }else {
                                var users = snapshot.data?.docs.reversed.toList() ?? [];
                                List<Widget> userViews = [];
                                DateTime now = DateTime.now();
                                DateFormat dateFormat = DateFormat("d/M/yyyy");
                                DateFormat timeFormat = DateFormat("h:mm a", "en_US");

                                for (var user in users) {
                                  String scheduledDateEnd = user["status"] == "Request sent"? user["ScheduledDate"] : user["ScheduledDateEnd"];
                                  String scheduledTimeEnd = user["status"] == "Request sent"? user["ScheduledTime"] : user["ScheduledTimeEnd"];
                                  DateTime endDate = dateFormat.parse(scheduledDateEnd);
                                  DateTime endTime = timeFormat.parse(scheduledTimeEnd);

                                  DateTime combinedEndDateTime = DateTime(
                                    endDate.year,
                                    endDate.month,
                                    endDate.day,
                                    endTime.hour,
                                    endTime.minute,
                                  );

                                  if (user["userUID"] == uid &&
                                      user['status'] != "Completed" &&
                                      !combinedEndDateTime.isBefore(now)) {
                                    userViews.add(
                                      FutureBuilder(
                                        future: Future.wait([
                                          getUserData(user['userUID']),
                                          getStaffData(user['professionOfStaff'],
                                              user['staffUID']),
                                        ]),
                                        builder: (context,
                                            AsyncSnapshot<List<dynamic>>
                                            snapshot) {
                                          if (!snapshot.hasData) {
                                            return LoaderSupport
                                                .loadingAnimation.widget;
                                          }

                                          var currentStaffData =
                                          snapshot.data?[1];

                                          return Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(
                                                        10.0),
                                                    child: Container(
                                                      width: screenWidth - 22,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                        boxShadow: const [
                                                          BoxShadow(
                                                            color: Colors.black26,
                                                            spreadRadius: 1,
                                                            blurRadius: 1,
                                                          )
                                                        ],
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                            EdgeInsets.only(
                                                                left: 10,
                                                                top: 10, right : 10),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  "Request To".trKey,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      20,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const Divider(),
                                                          SizedBox(
                                                            height: screenHeight *
                                                                0.1,
                                                            width: screenWidth *
                                                                0.85,
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  height: 70,
                                                                  width: 70,
                                                                  decoration:
                                                                  BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                        70),
                                                                    boxShadow: const [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black26,
                                                                        blurRadius:
                                                                        1,
                                                                        spreadRadius:
                                                                        1,
                                                                      )
                                                                    ],
                                                                    image:
                                                                    DecorationImage(
                                                                      image: NetworkImage(
                                                                          currentStaffData[
                                                                          'Profile_Pic']),
                                                                      fit: BoxFit
                                                                          .cover, // Adjust the fit if necessary
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                      10, right : 10),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                    children: [
                                                                      Text(
                                                                        "${currentStaffData?['First_name']} ${currentStaffData?['Last_name']}",
                                                                        overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                        maxLines:
                                                                        1,
                                                                        style: const TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                            16),
                                                                      ),
                                                                      Text(
                                                                          "${user['timeofdeal']}",
                                                                          style: const TextStyle(
                                                                              fontSize:
                                                                              12)),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                    children: [
                                                                      Text(
                                                                          "For".trKey,
                                                                          style: TextStyle(
                                                                              fontWeight:
                                                                              FontWeight.bold,
                                                                              fontSize: 12)),
                                                                      const Divider(),
                                                                      Text(
                                                                        "${user['professionOfStaff'].toString().substring(0, 1).toUpperCase()}${user['professionOfStaff'].toString().substring(1)}".trKey,
                                                                        overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                        maxLines:
                                                                        1,
                                                                        style: const TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            fontSize:
                                                                            18,
                                                                            color:
                                                                            Colors.red),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 10,
                                                                    top: 5,
                                                                    bottom:
                                                                    5, right : 10),
                                                                child: Container(
                                                                  height: 30,
                                                                  width:
                                                                  screenWidth *
                                                                      0.35,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius: BorderRadius.circular(5),
                                                                      boxShadow: const [
                                                                        BoxShadow(
                                                                            color: Colors
                                                                                .black26,
                                                                            blurRadius:
                                                                            1,
                                                                            spreadRadius:
                                                                            1)
                                                                      ]),
                                                                  child: Center(
                                                                      child: Text(
                                                                        "${user['ServiceBase']}".trKey,
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold),
                                                                      )),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 80,
                                                            width:
                                                            screenWidth - 50,
                                                            child: Column(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                      10, right : 10),
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                          child: Text(
                                                                              "${user['ServiceBase']}".trKey)),
                                                                      Text(
                                                                          "${user['hours']}"),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Divider(),
                                                                Padding(
                                                                  padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                      10, right : 10),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                          "Total".trKey,
                                                                          style: TextStyle(
                                                                              fontWeight:
                                                                              FontWeight.bold)),
                                                                      Padding(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                            10, right : 10),
                                                                        child: Text(
                                                                            "Know more".trKey,
                                                                            style:
                                                                            TextStyle(color: Colors.green)),
                                                                      ),
                                                                      const Spacer(),
                                                                      Text(
                                                                          "${user['totalcost'].toString()} ${currentStaffData['Currency'] ?? '-'}",
                                                                          style: const TextStyle(
                                                                              fontWeight:
                                                                              FontWeight.bold)),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Divider(),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            EdgeInsets.only(
                                                                left: 10, right : 10),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  "Schedule".trKey,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                      fontSize:
                                                                      18),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10.0,
                                                                right: 10.0),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  "${user['ScheduledDate']} ${user['ScheduledTime']}",
                                                                  style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                      12),
                                                                ),
                                                                Text(
                                                                  "until".trKey,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                      fontSize:
                                                                      13),
                                                                ),
                                                                Text(
                                                                  "${user['ScheduledDateEnd']} ${user['ScheduledTimeEnd']}",
                                                                  style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                      12),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            EdgeInsets.only(
                                                                left: 10, right : 10),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  "Location".trKey,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                      fontSize:
                                                                      18),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10, right : 10),
                                                            child: Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  SizedBox(
                                                                    width:
                                                                    screenWidth *
                                                                        0.8,
                                                                    child: Text(
                                                                      "${user['Scheduled_Sub_Address']}, ${user['Scheduled_Address']}, ${user['Scheduled_City']}",
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                          12),
                                                                    ),
                                                                  ),
                                                                ]),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                right: 10,
                                                                top: 5),
                                                            child: InkWell(
                                                              onTap: () {
                                                                if (user['Client_Coordinates_lat'] !=
                                                                    "" &&
                                                                    user['Client_Coordinates_long'] !=
                                                                        "") {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                            TempMap(
                                                                              lat: user[
                                                                              'Client_Coordinates_lat'],
                                                                              long: user[
                                                                              'Client_Coordinates_long'],
                                                                            ),
                                                                      ));
                                                                } else {
                                                                  Fluttertoast
                                                                      .showToast(
                                                                    msg:
                                                                    'Not Available'.trKey,
                                                                    gravity:
                                                                    ToastGravity
                                                                        .BOTTOM,
                                                                    toastLength: Toast
                                                                        .LENGTH_SHORT,
                                                                  );
                                                                }
                                                              },
                                                              child: Container(
                                                                height: 45,
                                                                width:
                                                                screenWidth -
                                                                    16,
                                                                decoration:
                                                                BoxDecoration(
                                                                    color: const Color(
                                                                        0xff2874f0),
                                                                    boxShadow: const [
                                                                      BoxShadow(
                                                                        color:
                                                                        Colors.black26,
                                                                        spreadRadius:
                                                                        1,
                                                                        blurRadius:
                                                                        1,
                                                                      )
                                                                    ],
                                                                    borderRadius:
                                                                    BorderRadius.circular(
                                                                        5)),
                                                                child:
                                                                Center(
                                                                  child: Text(
                                                                    "Check Map".trKey,
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 10.0,
                                                                  left: 10,
                                                                  bottom: 5),
                                                              child: GlowingBorderContainer(
                                                                  status: user['status'] == "Accepted"? "Staff Will Arrive On Time".trKey : user['status'] == "Rejected"? "Not Coming".trKey : user['status'] == "Request sent"? "Waiting for staff to accept".trKey : user['status']?? "Unknown".trKey)),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                right: 10,
                                                                top: 5),
                                                            child: InkWell(
                                                                onTap: () async {
                                                                  DocumentSnapshot
                                                                  doc =
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                      "user")
                                                                      .doc(user[
                                                                  "staffUID"])
                                                                      .get();
                                                                  var phoneNumber =
                                                                  doc["Phone_Number1"]
                                                                      .toString();
                                                                  final Uri
                                                                  phoneUri =
                                                                  Uri(
                                                                    scheme: 'tel',
                                                                    path: phoneNumber
                                                                        .toString(),
                                                                  );
                                                                  if (await canLaunchUrl(
                                                                      phoneUri)) {
                                                                    await launchUrl(
                                                                        phoneUri);
                                                                  } else {
                                                                    Fluttertoast
                                                                        .showToast(
                                                                        msg:
                                                                        "System Problem, Use Staff No. $phoneNumber");
                                                                  }
                                                                },
                                                                child:
                                                                GlowingBorderContainerPhone(
                                                                  Text:
                                                                  "Call Now".trKey,
                                                                  color: Colors
                                                                      .white,
                                                                  color1: Colors
                                                                      .black,
                                                                )),
                                                          ),
                                                          (user['status'] ==
                                                              "Accepted")
                                                              ? Padding(
                                                            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 10),
                                                            child: Text.rich(
                                                              TextSpan(
                                                                style: const TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors.black,
                                                                ),
                                                                children: [
                                                                  TextSpan(
                                                                    text: "Please give One Time Password(OTP) to Staff when staff reach the work location. \nOTP is ".trKey,
                                                                  ),
                                                                  TextSpan(
                                                                    text: " ${user['OTP'] ?? 'Invalid'.trKey}",
                                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                                  ),
                                                                ],
                                                              ),
                                                              textAlign: TextAlign.justify,
                                                            ),
                                                          )
                                                              : Container(),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    );
                                  }
                                }
                                if (userViews.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top : 200.0),
                                    child: Center(
                                        child: Text(
                                          "There are no any notifications".trKey,
                                          style: TextStyle(fontSize: 16),
                                        )),
                                  );
                                }
                                return Column(children: userViews);
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class GlowingBorderContainer extends StatefulWidget {
  final String status;
  const GlowingBorderContainer({super.key, required this.status});

  @override
  State<GlowingBorderContainer> createState() => _GlowingBorderContainerState();
}

class _GlowingBorderContainerState extends State<GlowingBorderContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final List<Color> _colors = [
    Colors.cyanAccent,
    Colors.purpleAccent,
    Colors.deepOrangeAccent,
    Colors.lightGreenAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  SweepGradient get rotatingGradient => SweepGradient(
        colors: [..._colors, _colors.first],
        stops: List.generate(_colors.length + 1, (i) => i / _colors.length),
        transform: GradientRotation(_controller.value * 2 * pi),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glowing border
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _BorderGlowPainter(rotatingGradient),
                ),
              );
            },
          ),

          // Inner white container with text
          Container(
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "${"Status : ".trKey} ${widget.status}",
                    softWrap: true,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GlowingBorderContainerPhone extends StatefulWidget {
  final String Text;
  final Color color;
  final Color color1;
  const GlowingBorderContainerPhone(
      {super.key,
      required this.Text,
      required this.color,
      required this.color1});

  @override
  State<GlowingBorderContainerPhone> createState() =>
      _GlowingBorderContainerStatePhone();
}

class _GlowingBorderContainerStatePhone
    extends State<GlowingBorderContainerPhone>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final List<Color> _colors = [
    Colors.cyanAccent,
    Colors.purpleAccent,
    Colors.deepOrangeAccent,
    Colors.lightGreenAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  SweepGradient get rotatingGradient => SweepGradient(
        colors: [..._colors, _colors.first],
        stops: List.generate(_colors.length + 1, (i) => i / _colors.length),
        transform: GradientRotation(_controller.value * 2 * pi),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glowing border
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _BorderGlowPainter(rotatingGradient),
                ),
              );
            },
          ),

          // Inner white container with text
          Container(
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: widget.color1,
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.Text,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter to draw rotating border
class _BorderGlowPainter extends CustomPainter {
  final Gradient gradient;
  _BorderGlowPainter(this.gradient);

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..shader = gradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(5));
    canvas.drawRRect(rRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _BorderGlowPainter oldDelegate) {
    return oldDelegate.gradient != gradient;
  }
}
