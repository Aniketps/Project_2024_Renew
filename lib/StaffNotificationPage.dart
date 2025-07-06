import 'dart:math';

import 'package:carehub/services/sendNotificationService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'LoaderSupport.dart';
import 'TempMap.dart';
import 'globle.dart';

class StaffNotificationPage extends StatefulWidget {
  const StaffNotificationPage({super.key});

  @override
  State<StatefulWidget> createState() => _StaffNotificationPage();
}

class _StaffNotificationPage extends State<StaffNotificationPage> {
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
  String? OTP;

  var NotificationForStaffUID;
  var NotificationForUserUID;
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
            color: Globle.theme,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppBar(
                  title: const Center(
                    child: Text("Notifications",
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
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("NotificationForStaff")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                            child: LoaderSupport.loadingAnimation.widget);
                      }
                      var users = snapshot.data?.docs.reversed.toList() ?? [];
                      List<Widget> userViews = [];
                      DateTime now = DateTime.now();
                      DateFormat dateFormat = DateFormat("d/M/yyyy");
                      DateFormat timeFormat = DateFormat("h:mm a");

                      for (var user in users) {
                        String scheduledDateEnd = user["ScheduledDateEnd"];
                        String scheduledTimeEnd = user["ScheduledTimeEnd"];
                        DateTime endDate = dateFormat.parse(scheduledDateEnd);
                        DateTime endTime = timeFormat.parse(scheduledTimeEnd);
                        DateTime combinedEndDateTime = DateTime(
                          endDate.year,
                          endDate.month,
                          endDate.day,
                          endTime.hour,
                          endTime.minute,
                        );
                        if (user["staffUID"] == uid &&
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
                                  AsyncSnapshot<List<dynamic>> snapshot) {
                                if (!snapshot.hasData) {
                                  return LoaderSupport
                                      .loadingAnimation.widget;
                                }

                                var currentUserData = snapshot.data?[0];
                                var currentStaffData = snapshot.data?[1];

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Container(
                                            width: screenWidth - 24,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
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
                                                          left: 10, top: 10),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "Request From",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Divider(),
                                                SizedBox(
                                                  height: screenHeight * 0.1,
                                                  width: screenWidth * 0.85,
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        height: 70,
                                                        width: 70,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      70),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black26,
                                                              blurRadius: 1,
                                                              spreadRadius: 1,
                                                            )
                                                          ],
                                                        ),
                                                        child: (currentUserData
                                                                    .containsKey(
                                                                        "Profile_Pic") &&
                                                                currentUserData[
                                                                        "Profile_Pic"] !=
                                                                    null &&
                                                                currentUserData[
                                                                        "Profile_Pic"]
                                                                    .isNotEmpty)
                                                            ? Container(
                                                                height: 70,
                                                                width: 70,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
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
                                                                        currentUserData[
                                                                            'Profile_Pic']),
                                                                    fit: BoxFit
                                                                        .cover, // Adjust the fit if necessary
                                                                  ),
                                                                ),
                                                              )
                                                            : const Icon(CupertinoIcons
                                                                .profile_circled),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "${currentUserData?['First_name']} ${currentUserData?['Last_name']}",
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
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
                                                            const Text("Need",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        12)),
                                                            const Divider(),
                                                            Text(
                                                              "${user['professionOfStaff'].toString().substring(0, 1).toUpperCase()}${user['professionOfStaff'].toString().substring(1)}",
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      18,
                                                                  color: Colors
                                                                      .red),
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
                                                              bottom: 5),
                                                      child: Container(
                                                        height: 30,
                                                        width: screenWidth *
                                                            0.25,
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
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
                                                          "${user['ServiceBase']} base",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0,
                                                          right: 10.0),
                                                  child: SizedBox(
                                                    height: 80,
                                                    width: screenWidth,
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                  child: Text(
                                                                      user[
                                                                          'ServiceBase'])),
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
                                                                  left: 10),
                                                          child: Row(
                                                            children: [
                                                              const Text("Total",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight.bold)),
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10),
                                                                child: Text(
                                                                    "Know more",
                                                                    style: TextStyle(
                                                                        color:
                                                                            Colors.green)),
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
                                                ),
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(
                                                          left: 10),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "Schedule",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            fontSize: 18),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                      const Text(
                                                        "Due To",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            fontSize: 13),
                                                      ),
                                                      Text(
                                                        "${user['ScheduledDateEnd']} ${user['ScheduledTimeEnd']}",
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                (user['status'] ==
                                                    "Rejected")
                                                    ? Container()
                                                    : const Padding(
                                                  padding:
                                                      EdgeInsets.only(
                                                          left: 10),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "Location",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            fontSize: 18),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                (user['status'] ==
                                                    "Rejected")
                                                    ? Container()
                                                    : Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width: screenWidth *
                                                              0.8,
                                                          child: Text(
                                                            "${user['Scheduled_Sub_Address']}, ${user['Scheduled_Address']}, ${user['Scheduled_City']}",
                                                            style: const TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                        ),
                                                      ]),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                (user['status'] ==
                                                    "Rejected")
                                                    ? Container()
                                                    : Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0,
                                                          right: 10.0),
                                                  child: InkWell(
                                                    onTap: () {
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
                                                    },
                                                    child: Container(
                                                      height: 45,
                                                      decoration:
                                                          BoxDecoration(
                                                              color: const Color(
                                                                  0xff2874f0),
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
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                      child: const Center(
                                                        child: Text(
                                                          "Show Direction",
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
                                                (user['status'] ==
                                                            "Rejected") ||
                                                        (user['status'] ==
                                                            "Accepted")
                                                    ? Container()
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10.0,
                                                                right: 10,
                                                                top: 10),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            InkWell(
                                                              onTap:
                                                                  () async {
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "NotificationForStaff")
                                                                    .doc(user
                                                                        .id)
                                                                    .update({
                                                                  'status':
                                                                      "Rejected",
                                                                });
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "NotificationForUser")
                                                                    .doc(user[
                                                                        'DocUID'])
                                                                    .update({
                                                                  'status':
                                                                      "Rejected",
                                                                });
                                                                var userDoc = await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "user")
                                                                    .doc(user[
                                                                        'userUID'])
                                                                    .get();
                                                                var usertoken =
                                                                    userDoc.data()?[
                                                                        'token'];
                                                                int notificationId1 =
                                                                    DateTime.now()
                                                                        .millisecondsSinceEpoch; // Unique ID based on timestamp
                                                                int notificationId2 =
                                                                    notificationId1 +
                                                                        1;
                                                                sendNotificationService.sendNotificationUsingApi(
                                                                    body: "🙁 ${currentStaffData?['First_name']} ${currentStaffData?['Last_name']} wasn’t available to take your job. 🤝 Feel free to try another staff member."
                                                                    ,data: {
                                                                          "screen": "ClientNotificationPage",
                                                                          "notificationId": notificationId2.toString(), // Include notification ID in the data if needed
                                                                        },
                                                                        title: "Request Status",
                                                                        token: usertoken);
                                                              },
                                                              child: const SizedBox(
                                                                  width: 150,
                                                                  child: GlowingBorderContainerPhone(
                                                                    color1: Colors
                                                                        .white,
                                                                    color: Colors
                                                                        .black,
                                                                    Text:
                                                                        "Reject",
                                                                  )),
                                                            ),
                                                            InkWell(
                                                              onTap:
                                                                  () async {
                                                                Random
                                                                    random =
                                                                    Random();
                                                                int genOPT = 1000 + random.nextInt(9000);

                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "NotificationForStaff")
                                                                    .doc(user
                                                                        .id)
                                                                    .update({
                                                                  'status':
                                                                      "Accepted",
                                                                  'OTP':
                                                                      genOPT,
                                                                  'Rating':
                                                                      "0",
                                                                });
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "NotificationForUser")
                                                                    .doc(user[
                                                                        'DocUID'])
                                                                    .update({
                                                                  'status':
                                                                      "Accepted",
                                                                  'OTP':
                                                                      genOPT,
                                                                  "Rating":
                                                                      "0",
                                                                });

                                                                var userDoc = await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "user")
                                                                    .doc(user[
                                                                        'userUID'])
                                                                    .get();
                                                                var usertoken =
                                                                    userDoc.data()?[
                                                                        'token'];
                                                                int notificationId1 =
                                                                    DateTime.now()
                                                                        .millisecondsSinceEpoch; // Unique ID based on timestamp
                                                                int notificationId2 =
                                                                    notificationId1 +
                                                                        1;
                                                                sendNotificationService
                                                                    .sendNotificationUsingApi(
                                                                    body: "🟢 Your request has been accepted by ${currentStaffData?['First_name']} ${currentStaffData?['Last_name']}. They'll arrive as scheduled. 😊",
                                                                        data: {
                                                                          "screen":
                                                                              "ClientNotificationPage",
                                                                          "notificationId":
                                                                              notificationId2.toString(),
                                                                        },
                                                                        title:
                                                                            "Request Status",
                                                                        token:
                                                                            usertoken);
                                                              },
                                                              child: const SizedBox(
                                                                  width: 150,
                                                                  child: GlowingBorderContainerPhone(
                                                                    color1: Colors
                                                                        .white,
                                                                    color: Colors
                                                                        .black,
                                                                    Text:
                                                                        "Accept",
                                                                  )),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                (user['status'] ==
                                                    "Received a Request") ||
                                                    (user['status'] ==
                                                        "Accepted")
                                                    ? Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .only(
                                                      left: 10.0,
                                                      right: 10,
                                                      top: 10),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    children: [
                                                      InkWell(
                                                        onTap:
                                                            () async {
                                                              var phoneNumber = user["clientContact"].toString();
                                                              final Uri phoneUri = Uri(
                                                                    scheme: 'tel',
                                                                    path: phoneNumber
                                                                        .toString(),
                                                                  );
                                                              if (await canLaunchUrl(phoneUri)) {
                                                                await launchUrl(phoneUri);
                                                              } else {
                                                                Fluttertoast.showToast(
                                                                    msg: "System Problem, Use Staff No. $phoneNumber");
                                                              }
                                                        },
                                                        child: Container(
                                                            width: screenWidth - 48,
                                                            height: 50,
                                                            decoration: BoxDecoration(
                                                              color: Colors.black,
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
                                                            child: const Center(
                                                              child: Text("Call For More Information", style : TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                                            )),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                                    : Container(),
                                                (user['status'] == "Accepted")
                                                    ? Padding(
                                                      padding: const EdgeInsets.only(right : 14.0, left : 12.0, top: 10),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          const Padding(
                                                            padding: EdgeInsets.all(5.0),
                                                            child: Text("Please take One Time Password (OTP) from Client when you reach the destination for the staff verification.", textAlign: TextAlign.justify,),
                                                          ),
                                                          Container(
                                                            height: 50,
                                                            width: screenWidth,
                                                            decoration: BoxDecoration(
                                                                color: Colors.white,
                                                                borderRadius: BorderRadius.circular(5),
                                                                boxShadow: const [BoxShadow(
                                                                    color: Colors.black26,
                                                                    blurRadius: 1,
                                                                    spreadRadius: 1
                                                                )]
                                                            ),
                                                            child: TextField(
                                                              onChanged:
                                                                  (value) async {
                                                                setState(() {
                                                                  OTP =
                                                                      value; // Store the entered OTP in the state
                                                                });

                                                                // Automatically check OTP when it's fully entered (assuming OTP is 4 digits)
                                                                if (OTP?.length ==
                                                                    4) {
                                                                  if (OTP ==
                                                                      user['OTP']
                                                                          .toString()) {
                                                                    // OTP is correct, update the status to 'Completed'
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                        "NotificationForStaff")
                                                                        .doc(user
                                                                        .id)
                                                                        .update({
                                                                      "status":
                                                                      'Completed',
                                                                    });
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                        "NotificationForUser")
                                                                        .doc(user[
                                                                    'DocUID'])
                                                                        .update({
                                                                      "status":
                                                                      'Completed',
                                                                    });
                                                                    var userDoc = await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                        "user")
                                                                        .doc(user[
                                                                    'userUID'])
                                                                        .get();
                                                                    var usertoken =
                                                                    userDoc.data()?[
                                                                    'token'];
                                                                    int notificationId1 =
                                                                        DateTime.now()
                                                                            .millisecondsSinceEpoch; // Unique ID based on timestamp
                                                                    int notificationId2 =
                                                                        notificationId1 +
                                                                            1;
                                                                    sendNotificationService.sendNotificationUsingApi(
                                                                        body: "✅ Your job with ${currentStaffData?['First_name']} ${currentStaffData?['Last_name']} has officially started. Thank you for choosing CareNest!💙",
                                                                        data: {
                                                                          "screen":
                                                                          "ClientNotificationPage",
                                                                          "notificationId":
                                                                          notificationId2.toString(), // Include notification ID in the data if needed
                                                                        },
                                                                        title: "Staff Status",
                                                                        token: usertoken);
                                                                    ScaffoldMessenger.of(
                                                                        context)
                                                                        .showSnackBar(
                                                                      const SnackBar(
                                                                          content:
                                                                          Text("OTP Verified!")),
                                                                    );
                                                                  } else {
                                                                    // OTP is incorrect, show error message
                                                                    ScaffoldMessenger.of(
                                                                        context)
                                                                        .showSnackBar(
                                                                      const SnackBar(
                                                                          content:
                                                                          Text("Invalid OTP!")),
                                                                    );
                                                                  }
                                                                }
                                                              },
                                                              decoration:
                                                              InputDecoration(
                                                                  hintText:
                                                                  "OTP", // Placeholder text
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
                                                        ],
                                                      )
                                                    )
                                                    : Container(),
                                                const SizedBox(height: 10,)
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
                ),
              ),
            ],
          )
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
