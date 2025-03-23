import 'package:carehub/TempMap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'LoaderSupport.dart';

class ClientNotificationPage extends StatefulWidget {
  const ClientNotificationPage({super.key});

  @override
  State<StatefulWidget> createState() => _ClientNotificationPageState();
}

class _ClientNotificationPageState extends State<ClientNotificationPage> {
  @override
  void initState() {
    super.initState();
    void liveLocation() {
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) {
          setState(() async {
            String lat = position.latitude.toString();
            String long = position.longitude.toString();
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
    }

    liveLocation();
  }

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
      body: Stack(
        children: [
          // App bar section
          Container(
            height: 150,
            color: const Color(0xfffffcc9),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppBar(
                  title: const Center(
                    child: Text("Notifications",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  backgroundColor: const Color(0xfffffcc9),
                  automaticallyImplyLeading: false,
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 150),
                child: Container(
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
                              if (!snapshot.hasData) {
                                return Center(
                                    child: LoaderSupport.loadingAnimation.widget);
                              }
                              var users =
                                  snapshot.data?.docs.reversed.toList() ?? [];
                              List<Widget> userViews = [];
                              DateTime now = DateTime.now();
                              DateFormat dateFormat = DateFormat("d/M/yyyy");
                              DateFormat timeFormat = DateFormat("h:mm a");

                              for (var user in users) {
                                String scheduledDateEnd =
                                    user["ScheduledDateEnd"];
                                String scheduledTimeEnd =
                                    user["ScheduledTimeEnd"];
                                DateTime endDate =
                                    dateFormat.parse(scheduledDateEnd);
                                DateTime endTime =
                                    timeFormat.parse(scheduledTimeEnd);
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
                                          return LoaderSupport.loadingAnimation.widget;
                                        }

                                        var currentUserData = snapshot.data?[0];
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
                                                    height: screenHeight * 0.63,
                                                    width: screenWidth * 0.9,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
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
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20,
                                                                  top: 10),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                "Request To",
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
                                                                            10),
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
                                                                    const Text(
                                                                        "For",
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize: 12)),
                                                                    const Divider(),
                                                                    Text(
                                                                      "${user['professionOfStaff']}",
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
                                                                      left: 25,
                                                                      top: 5,
                                                                      bottom:
                                                                          5),
                                                              child: Container(
                                                                height: 30,
                                                                width:
                                                                    screenWidth *
                                                                        0.25,
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
                                                                  user[
                                                                      'ServiceBase'],
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
                                                          width: screenWidth *
                                                              0.75,
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                        child: Text(
                                                                            user['ServiceBase'])),
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
                                                                            10),
                                                                child: Row(
                                                                  children: [
                                                                    const Text(
                                                                        "Total",
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold)),
                                                                    const Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              10),
                                                                      child: Text(
                                                                          "Know more",
                                                                          style:
                                                                              TextStyle(color: Colors.green)),
                                                                    ),
                                                                    const Spacer(),
                                                                    Text(
                                                                        user['totalcost']
                                                                            .toString(),
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
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 25),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                "Schedule",
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
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SizedBox(
                                                              width:
                                                                  screenWidth *
                                                                      0.3,
                                                              child: Center(
                                                                child: Text(
                                                                  "${user['ScheduledDate']} ${user['ScheduledTime']}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          9),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  screenWidth *
                                                                      0.15,
                                                              child:
                                                                  const Center(
                                                                child: Text(
                                                                  "Due To",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          9),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  screenWidth *
                                                                      0.3,
                                                              child: Center(
                                                                child: Text(
                                                                  "${user['ScheduledDateEnd']} ${user['ScheduledTimeEnd']}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          9),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 25),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                "Location",
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
                                                                  left: 25),
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
                                                                            10),
                                                                  ),
                                                                ),
                                                              ]),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 25,
                                                                  top: 10),
                                                          child: Row(
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  if (user['Client_Coordinates_lat'] !=
                                                                          "" &&
                                                                      user['Client_Coordinates_long'] !=
                                                                          "") {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              TempMap(
                                                                            lat:
                                                                                user['Client_Coordinates_lat'],
                                                                            long:
                                                                                user['Client_Coordinates_long'],
                                                                          ),
                                                                        ));
                                                                  } else {
                                                                    Fluttertoast
                                                                        .showToast(
                                                                      msg:
                                                                          'Not Available',
                                                                      gravity:
                                                                          ToastGravity
                                                                              .BOTTOM,
                                                                      toastLength:
                                                                          Toast
                                                                              .LENGTH_SHORT,
                                                                    );
                                                                  }
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 30,
                                                                  width:
                                                                      screenWidth *
                                                                          0.3,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                    color: Colors
                                                                        .white,
                                                                    boxShadow: const [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black26,
                                                                        spreadRadius:
                                                                            1,
                                                                        blurRadius:
                                                                            1,
                                                                      )
                                                                    ],
                                                                  ),
                                                                  child:
                                                                      const Center(
                                                                    child: Text(
                                                                      "Check Map",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Text(
                                                            "${user['status']}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        20),
                                                          ),
                                                        ),
                                                        (user['status'] ==
                                                                "Accepted")
                                                            ? Text(
                                                                "${user['OTP'] ?? 'Invalid'}",
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        18),
                                                              )
                                                            : Container(),
                                                        InkWell(
                                                          onTap: () async {
                                                            DocumentSnapshot doc = await FirebaseFirestore.instance.collection("user").doc(user["staffUID"]).get();
                                                            var phoneNumber = doc["Phone_Number1"].toString();
                                                            final Uri phoneUri = Uri(
                                                              scheme: 'tel',
                                                              path: phoneNumber.toString(),
                                                            );
                                                            if (await canLaunchUrl(
                                                                phoneUri)) {
                                                              await launchUrl(phoneUri);
                                                            } else {
                                                              Fluttertoast.showToast(msg: "System Problem, Use Staff No. $phoneNumber");
                                                            }
                                                          },
                                                          child: Container(
                                                              height: 50,
                                                              width: 50,
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(50),
                                                                color: Colors.green
                                                              ),
                                                              child: Center(child: Icon(Icons.call_rounded, size: 30, color: Colors.white,))),
                                                        )
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
                              return Column(children: userViews);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
