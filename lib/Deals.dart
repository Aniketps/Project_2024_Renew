import 'package:carehub/StaffProfilePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Deals extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Deals();
}

class _Deals extends State<Deals> {
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
        title: Text("Deals History"),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("NotificationForUser")
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            var users = snapshot.data?.docs.reversed.toList() ?? [];
            List<Widget> userViews = [];

            for (var user in users) {
              if (user["userUID"] == uid && user['status'] == "Completed") {
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
                                  height: screenHeight * 0.37,
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
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Container(
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
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        currentStaffData[
                                                        'Profile_Pic']),
                                                    fit: BoxFit
                                                        .cover, // Adjust the fit if necessary
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${currentStaffData?['First_name']} ${currentStaffData?['Last_name']}",
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                    Text("${currentStaffData['Status']? "Available":"Busy"}",
                                                        style: TextStyle(
                                                            fontSize: 10, color: Colors.green)),
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
                                                    Text("For",
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
                                        const EdgeInsets.only(left: 30),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Overall Service Rating",
                                                  style: TextStyle(
                                                      fontSize: 12),
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(Icons.star, color: Color(0xffFFD700),),
                                                    Icon(Icons.star, color: Color(0xffFFD700),),
                                                    Icon(Icons.star, color: Color(0xffFFD700),),
                                                    Icon(Icons.star, color: Color(0xffFFD700),),
                                                    Icon(Icons.star, color: Color(0xffFFD700),),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 25),
                                              child: ElevatedButton(onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => StaffProfilePage(StaffID: user['staffUID'], Skill: currentStaffData['professionOfStaff']),));
                                              },style:  ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10)
                                                )
                                              ),
                                                  child: Text("Deal Again", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
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
