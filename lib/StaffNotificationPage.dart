import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class StaffNotificationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StaffNotificationPage();
}

class _StaffNotificationPage extends State<StaffNotificationPage> {


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

  User? currentUser = FirebaseAuth.instance.currentUser;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

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
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("NotificationForStaff").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            var users = snapshot.data?.docs.reversed.toList() ?? [];
            List<Widget> userViews = [];

            for (var user in users) {
              if (user["staffUID"] == uid && user['status'] != "Completed") {
                userViews.add(
                  FutureBuilder(
                    future: Future.wait([
                      getUserData(user['userUID']),
                      getStaffData(user['professionOfStaff'], user['staffUID']),
                    ]),
                    builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();

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
                                  height: screenHeight * 0.62,
                                  width: screenWidth * 0.9,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
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
                                        padding: const EdgeInsets.only(
                                            left: 20, top: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Request From",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(),
                                      Container(
                                        height: screenHeight * 0.1,
                                        width: screenWidth * 0.85,
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 70,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                BorderRadius.circular(70),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 1,
                                                    spreadRadius: 1,
                                                  )
                                                ],
                                              ),
                                              child: Icon(CupertinoIcons.profile_circled),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${currentUserData?['First_name']} ${currentUserData?['Last_name']}",
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                  Text("${user['timeofdeal']}",
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Text("Need",
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize: 12)),
                                                  Divider(),
                                                  Text(
                                                    "${user['professionOfStaff']}",
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 18,
                                                        color: Colors.red),
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
                                            padding: const EdgeInsets.only(left: 25, top: 5, bottom: 5),
                                            child: Container(
                                              height: 30,
                                              width: screenWidth * 0.25,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(5),
                                                  boxShadow: [BoxShadow(
                                                      color: Colors.black26,
                                                      blurRadius: 1,
                                                      spreadRadius: 1
                                                  )]
                                              ),
                                              child: Center(child: Text("Hour base", style: TextStyle(fontWeight: FontWeight.bold),)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        height: 80,
                                        width: screenWidth * 0.75,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: Text("Hours")),
                                                  Text("${user['hours']}"),
                                                ],
                                              ),
                                            ),
                                            Divider(),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Row(
                                                children: [
                                                  Text("Total",
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.bold)),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 10),
                                                    child: Text("Know more",
                                                        style: TextStyle(
                                                            color: Colors.green)),
                                                  ),
                                                  Spacer(),
                                                  Text("145",
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                            Divider(),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(left: 25),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Schedule",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: screenWidth * 0.3,
                                            child: Center(
                                              child: Text(
                                                "21/09/2024 06:00 PM",
                                                style: TextStyle(fontSize: 9),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: screenWidth * 0.15,
                                            child: Center(
                                              child: Text(
                                                "Due To",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 9),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: screenWidth * 0.3,
                                            child: Center(
                                              child: Text(
                                                "21/09/2024 07:00 PM",
                                                style: TextStyle(fontSize: 9),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(left: 25),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Location",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(left: 25),
                                        child: Row(children: [
                                          Container(
                                            width: screenWidth * 0.8,
                                            child: Center(
                                                child: Text(
                                                  "06, Appashree complex, Awhalwadi, Wagholi, Pune, Maharashtra, 412207",
                                                  style: TextStyle(fontSize: 10),
                                                )),
                                          ),
                                        ]),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 25, top: 10),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 30,
                                              width: screenWidth * 0.3,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(8),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    spreadRadius: 1,
                                                    blurRadius: 1,
                                                  )
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "Check Map",
                                                  style:
                                                  TextStyle(fontSize: 13),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      (user['status']=="Rejected") || (user['status']=="Accepted")?
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Text(
                                          "${user['status']}",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ):
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: ElevatedButton(onPressed: () async {
                                              await FirebaseFirestore.instance.collection("NotificationForStaff").doc(user.id).update({
                                                'status': "Rejected",
                                              });
                                              await FirebaseFirestore.instance.collection("NotificationForUser").doc(user['DocUID']).update({
                                                'status': "Rejected",
                                              });
                                            },style:ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape:RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(40)
                                              )
                                            )
                                                ,child: Text('Reject')),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: ElevatedButton(onPressed: () async {
                                              await FirebaseFirestore.instance.collection("NotificationForStaff").doc(user.id).update({
                                                'status': "Accepted",
                                              });
                                              await FirebaseFirestore.instance.collection("NotificationForUser").doc(user['DocUID']).update({
                                                'status': "Accepted",
                                              });
                                            },style:ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                shape:RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(40)
                                                )
                                            )
                                                ,child: Text('Accept')),
                                          ),

                                        ],
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
            return Column(children: userViews);
          },
        ),
      ),
    );
  }
}
